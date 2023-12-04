import { Inject } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { RedisClientType } from 'redis';
import { parse } from 'url';
import { v1 as uuid } from 'uuid';
import * as WebSocket from 'ws';
import { SharedChecklistsService } from './shared-checklists.service';

/**
 * 웹소켓 통신을 통해 클라이언트들의 체크리스트 공유를 관리하는 게이트웨이.
 */
@WebSocketGateway({ path: '/share-checklist' })
export class SharedChecklistsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  constructor(
    private readonly sharedChecklistsService: SharedChecklistsService,
    @Inject('REDIS_CLIENT')
    private readonly redisClient: RedisClientType,
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
    @Inject('REDIS_SUB_CLIENT')
    private readonly redisSubscriber: RedisClientType,
  ) {
    // 서버 식별자 생성
    this.serverUuid = uuid();
    // Redis 구독 초기화
    this.initializeRedisSubscriber();
  }
  @WebSocketServer() server: WebSocket.Server;

  // 각 checklist ID별로 연결된 클라이언트들을 추적하기 위한 맵
  private clients: Map<string, Set<WebSocket>> = new Map();
  // 서버 식별자
  private serverUuid: string;

  /**
   * 클라이언트가 연결을 시도할 때 호출되는 메서드.
   * 연결된 클라이언트에 sharedChecklistId를 할당하고 관리한다.
   * @param client 연결된 클라이언트의 웹소켓 객체
   */
  async handleConnection(@ConnectedSocket() client: WebSocket, ...args: any[]) {
    const sharedChecklistId = this.getSharedChecklistId(args[0]);
    if (!sharedChecklistId)
      return { event: 'error', data: 'No sharedChecklistId provided' };
    client['sharedChecklistId'] = sharedChecklistId;

    this.addClientToMap(client, sharedChecklistId);
    await this.updateRedisCount(sharedChecklistId, true);
    await this.sendHistoryToClient(client, sharedChecklistId);
  }

  /**
   * 클라이언트 연결이 해제될 때 호출되는 메서드.
   * 해당 클라이언트를 관리 목록에서 제거한다.
   * @param client 연결 해제된 클라이언트의 웹소켓 객체
   */
  async handleDisconnect(@ConnectedSocket() client: WebSocket) {
    const sharedChecklistId = client['sharedChecklistId'];
    if (!(sharedChecklistId && this.clients.has(sharedChecklistId))) return;

    this.removeClientFromMap(client, sharedChecklistId);
    const count = await this.updateRedisCount(sharedChecklistId, false);
    if (count === 0) {
      await this.handleNoClientsConnected(sharedChecklistId);
    }
  }

  /**
   * 더 이상 연결된 클라이언트가 없을 때 처리하는 메서드이다.
   * 레디스의 sharedChecklistHistory를 postgres DB에 저장 후, Redis에서 해당 키를 삭제한다.
   * @param sharedChecklistId 공유 체크리스트의 식별자
   */
  private async handleNoClientsConnected(sharedChecklistId: string) {
    const redisArrayKey = `sharedChecklistHistory:${sharedChecklistId}`;
    const history = await this.redisClient.lRange(redisArrayKey, 0, -1);
    if (history.length > 0) {
      await this.saveToDatabase(sharedChecklistId, history);
      await this.redisClient.del(redisArrayKey);
    }
  }
  /**
   * 요청으로부터 sharedChecklistId를 추출하는 메서드이다.
   * 클라이언트의 요청 URL에서 sharedChecklistId를 파싱하여 반환한다.
   * @param request 클라이언트의 요청 객체
   * @returns 추출된 sharedChecklistId
   */
  private getSharedChecklistId(request: { url: string }) {
    const { query } = parse(request.url, true);
    const sharedChecklistId = query.cid as string;
    return sharedChecklistId;
  }

  /**
   * 클라이언트를 로컬 관리 맵에 추가하는 메서드이다.
   * sharedChecklistId에 해당하는 클라이언트 집합이 없으면 새로 생성하고, 클라이언트를 추가한다.
   * @param client 추가할 클라이언트의 웹소켓 객체
   * @param sharedChecklistId 공유 체크리스트의 식별자
   */ private addClientToMap(client: WebSocket, sharedChecklistId: string) {
    if (!this.clients.has(sharedChecklistId)) {
      this.clients.set(sharedChecklistId, new Set());
    }
    this.clients.get(sharedChecklistId)?.add(client);
  }

  /**
   * 클라이언트를 로컬 관리 맵에서 제거하는 메서드이다.
   * sharedChecklistId에 해당하는 클라이언트 집합에서 클라이언트를 제거한다.
   * 해당 집합의 크기가 0이 되면, 집합 자체를 맵에서 제거한다.
   * @param client 제거할 클라이언트의 웹소켓 객체
   * @param sharedChecklistId 공유 체크리스트의 식별자
   */
  private removeClientFromMap(client: WebSocket, sharedChecklistId: string) {
    const clientsSet = this.clients.get(sharedChecklistId);
    clientsSet?.delete(client);
    if (clientsSet?.size === 0) {
      this.clients.delete(sharedChecklistId);
    }
  }

  /**
   * Redis에 sharedChecklistId 클라이언트 수를 업데이트하는 메서드이다.
   * 클라이언트가 연결되면 카운트를 증가시키고, 연결이 해제되면 감소시킨다.
   * @param sharedChecklistId 공유 체크리스트의 식별자
   * @param isConnecting 클라이언트가 연결 중인지 여부 (연결 중이면 true, 연결 해제 중이면 false)
   * @returns 업데이트된 클라이언트 수
   */
  private async updateRedisCount(
    sharedChecklistId: string,
    isConnecting: boolean,
  ) {
    const redisCountKey = `sharedChecklistCount:${sharedChecklistId}`;
    if (isConnecting) {
      await this.redisClient.INCR(redisCountKey);
    } else {
      await this.redisClient.DECR(redisCountKey);
    }
    return parseInt(await this.redisClient.GET(redisCountKey), 10);
  }

  /**
   * sharedChecklistId 클라이언트에 누적 데이터값을 전송하는 메서드이다.
   * sharedChecklistId에 해당하는 누적 데이터값을 Redis에서 조회하여 클라이언트에 전송한다.
   * @param client 이력을 전송할 클라이언트의 웹소켓 객체
   * @param sharedChecklistId 공유 체크리스트의 식별자
   */
  private async sendHistoryToClient(
    client: WebSocket,
    sharedChecklistId: string,
  ) {
    const redisArrayKey = `sharedChecklistHistory:${sharedChecklistId}`;
    const history = await this.redisClient.lRange(redisArrayKey, 0, -1);
    if (history.length > 0) {
      this.sendToClient(client, 'history', history);
    }
  }

  /**
   * Redis 구독을 초기화하는 메서드이다.
   * 'sharedChecklist' 채널로부터 메시지를 받으면 해당 메시지를 로컬 클라이언트들에게 브로드캐스트한다.
   */
  private initializeRedisSubscriber() {
    this.redisSubscriber.subscribe('sharedChecklist', (message) => {
      const { serverUuid, sharedChecklistId, event, data } =
        JSON.parse(message);
      if (serverUuid !== this.serverUuid) {
        this.broadcastToLocal(sharedChecklistId, event, data);
      }
    });
  }
  /**
   * 특정 sharedChecklistId를 가진 클라이언트들에게 이벤트와 데이터를 브로드캐스트하는 메서드이다.
   * 메시지를 보낸 클라이언트는 브로드캐스트에서 제외한다.
   * @param sharedChecklistId 브로드캐스트 대상의 checklist ID
   * @param event 브로드캐스트할 이벤트 이름
   * @param data 전송할 데이터
   * @param excludeClient 브로드캐스트에서 제외할 클라이언트
   */
  private broadcastToLocal(
    sharedChecklistId: string,
    event: string,
    data: any,
    excludeClient?: WebSocket,
  ) {
    const clients = this.clients.get(sharedChecklistId);
    if (clients) {
      clients.forEach((client) => {
        if (client !== excludeClient && client.readyState === WebSocket.OPEN) {
          this.sendToClient(client, event, data);
        }
      });
    }
  }

  /**
   * 'send' 이벤트에 대한 요청을 처리하고, 해당 sharedChecklistId를 가진 다른 클라이언트들에게 'listen' 이벤트를 브로드캐스트하는 메서드이다.
   * 또한, Redis 채널에 게시하여 다른 서버에도 'listen' 이벤트를 브로드캐스트한다.
   * @param client 메시지를 보낸 클라이언트의 웹소켓 객체
   * @param data 클라이언트로부터 받은 데이터
   * @returns 이벤트 처리 결과를 나타내는 객체
   */
  @SubscribeMessage('send')
  async handleSendChecklist(
    @ConnectedSocket() client: WebSocket,
    @MessageBody() data: string,
    sharedChecklistId: string = client['sharedChecklistId'],
  ) {
    this.broadcastToLocal(sharedChecklistId, 'listen', data, client);
    const serverUuid = this.serverUuid;
    const message = JSON.stringify({
      serverUuid,
      sharedChecklistId,
      event: 'listen',
      data,
    });
    this.redisPublisher.publish('sharedChecklist', message);
    const redisArrayKey = `sharedChecklistHistory:${sharedChecklistId}`;
    this.redisClient.rPush(redisArrayKey, data);
  }

  @SubscribeMessage('editing')
  async handleEditingChecklist(
    @ConnectedSocket() client: WebSocket,
    @MessageBody() data: string,
    sharedChecklistId: string = client['sharedChecklistId'],
  ) {
    this.broadcastToLocal(sharedChecklistId, 'editing', data, client);
    const serverUuid = this.serverUuid;
    const message = JSON.stringify({
      serverUuid,
      sharedChecklistId,
      event: 'editing',
      data,
    });
    this.redisPublisher.publish('sharedChecklist', message);
  }
  /**
   * 특정 클라이언트에 이벤트와 데이터를 전송한다.
   * @param client 데이터를 전송할 클라이언트의 웹소켓 객체
   * @param event 전송할 이벤트 이름
   * @param data 전송할 데이터
   */
  private sendToClient(
    client: WebSocket,
    event: string,
    data: string[] | string,
  ) {
    client.send(JSON.stringify({ event, data }));
  }

  /**
   * sharedChecklistId에 해당하는 데이터를 데이터베이스에 저장하는 메서드이다.
   * 데이터가 누적되면 sharedChecklistsService를 통해 데이터베이스에 저장한다.
   * @param sharedChecklistId 공유 체크리스트의 식별자
   * @param dataForThisChecklist 저장할 데이터 목록
   */
  private async saveToDatabase(sharedChecklistId: string, history: string[]) {
    const now = new Date();
    await this.sharedChecklistsService.createSharedChecklistItem(
      history,
      sharedChecklistId,
      now,
    );
  }
}
