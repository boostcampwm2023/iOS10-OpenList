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
    this.serverUuid = uuid();
    this.redisSubscriber.subscribe('sharedChecklist', (message) =>
      this.handleRedisSubscribe(message),
    );
  }
  @WebSocketServer() server: WebSocket.Server;

  // 각 checklist ID별로 연결된 클라이언트들을 추적하기 위한 맵
  private clients: Map<string, Set<WebSocket>> = new Map();
  // // 각 checklist ID별로 전송된 데이터를 저장하기 위한 맵
  // private checklistData: Map<string, string[]> = new Map();
  // // 각 checklist ID별로 마지막 데이터 저장 시간을 추적하기 위한 맵
  // private checklistItemDate: Map<string, Date> = new Map();
  // 서버 식별자
  private serverUuid: string;

  /**
   * 클라이언트가 연결을 시도할 때 호출되는 메서드.
   * 연결된 클라이언트에 sharedChecklistId를 할당하고 관리한다.
   * @param client 연결된 클라이언트의 웹소켓 객체
   */
  async handleConnection(@ConnectedSocket() client: WebSocket, ...args: any[]) {
    const request = args[0];
    const { query } = parse(request.url, true);
    const sharedChecklistId = query.cid as string;

    // 클라이언트에 할당된 sharedChecklistId를 바탕으로 클라이언트 관리
    if (!sharedChecklistId)
      return { event: 'error', data: 'No sharedChecklistId provided' };
    client['sharedChecklistId'] = sharedChecklistId;

    if (!this.clients.has(sharedChecklistId)) {
      this.clients.set(sharedChecklistId, new Set());
    }
    this.clients.get(sharedChecklistId)?.add(client);

    const redisCountKey = `checklist:${sharedChecklistId}:count`;
    await this.redisClient.INCR(redisCountKey);
    const count = await this.redisClient.GET(redisCountKey);
    console.log('count:', count);

    const redisArrayKey = `array:${sharedChecklistId}`;
    const history = await this.redisClient.lRange(redisArrayKey, 0, -1);
    if (history.length > 0) {
      this.sendToClient(client, 'history', history);
    }
    // // 해당 방에 소켓 통신 중 데베에 저장된 데이터가 있는 경우 해당 데이터의 버전(시간)을 전송
    // const lastSavedDate = this.checklistItemDate.get(sharedChecklistId);
    // const dataForThisChecklist = this.checklistData.get(sharedChecklistId);
    // if (lastSavedDate) {
    //   this.sendToClient(client, 'lastDate', lastSavedDate.toISOString());
    // }
    // if (dataForThisChecklist) {
    //   this.sendToClient(client, 'history', dataForThisChecklist);
    // }
  }

  /**
   * 클라이언트 연결이 해제될 때 호출되는 메서드.
   * 해당 클라이언트를 관리 목록에서 제거한다.
   * @param client 연결 해제된 클라이언트의 웹소켓 객체
   */
  async handleDisconnect(@ConnectedSocket() client: WebSocket) {
    const sharedChecklistId = client['sharedChecklistId'];
    if (!(sharedChecklistId && this.clients.has(sharedChecklistId))) {
      return { event: 'error', data: 'No sharedChecklistId provided' };
    }
    const clientsSet = this.clients.get(sharedChecklistId);
    clientsSet?.delete(client);

    const redisCountKey = `checklist:${sharedChecklistId}:count`;
    await this.redisClient.DECR(redisCountKey);
    const count = await this.redisClient.GET(redisCountKey);
    console.log('count:', count);

    // 더 이상 해당 sharedChecklistId에 연결된 클라이언트가 없으면 맵에서 제거
    // 해당 sharedChecklistId에 저장된 데이터를 DB에 저장하고 맵에서 제거
    // 해당 sharedChecklistId에 저장된 마지막 데이터 저장 시간을 맵에서 제거
    if (clientsSet?.size === 0) {
      // this.saveAndBroadcastData(
      //   sharedChecklistId,
      //   this.checklistData.get(sharedChecklistId),
      // );
      // this.checklistData.delete(sharedChecklistId);
      // this.checklistItemDate.delete(sharedChecklistId);
      this.clients.delete(sharedChecklistId);
    }
    if (count === '0') {
      const redisArrayKey = `array:${sharedChecklistId}`;
      const history = await this.redisClient.lRange(redisArrayKey, 0, -1);
      if (history.length > 0) {
        this.saveAndBroadcastData(sharedChecklistId, history);
      }
      this.redisClient.del(redisArrayKey);
    }
  }

  private async handleRedisSubscribe(message: string) {
    const { serverUuid, sharedChecklistId, data } = JSON.parse(message);
    if (serverUuid !== this.serverUuid) {
      this.broadcastToChecklist(sharedChecklistId, 'listen', data);
    }
  }
  /**
   * 특정 sharedChecklistId를 가진 클라이언트들에게 이벤트와 데이터를 브로드캐스트한다.
   * 메시지를 보낸 클라이언트는 브로드캐스트에서 제외한다.
   * @param sharedChecklistId 브로드캐스트 대상의 checklist ID
   * @param event 브로드캐스트할 이벤트 이름
   * @param data 전송할 데이터
   * @param excludeClient 브로드캐스트에서 제외할 클라이언트
   */
  private broadcastToChecklist(
    sharedChecklistId: string,
    event: string,
    data: any,
    excludeClient?: WebSocket,
  ) {
    const clients = this.clients.get(sharedChecklistId);
    if (clients) {
      clients.forEach((client) => {
        if (client !== excludeClient && client.readyState === WebSocket.OPEN) {
          // client.send(JSON.stringify({ event, data }));
          this.sendToClient(client, event, data);
        }
      });
    }
  }

  /**
   * 'send' 이벤트에 대한 요청을 처리하고, 해당 sharedChecklistId를 가진 다른 클라이언트들에게 'listen' 이벤트를 브로드캐스트한다.
   * 데이터가 20개 누적될 때마다 데이터베이스에 저장하고, 'saved' 이벤트를 브로드캐스트한다.
   * @param client 메시지를 보낸 클라이언트의 웹소켓 객체
   * @param data 클라이언트로부터 받은 데이터
   * @returns 이벤트 처리 결과를 나타내는 객체
   */
  @SubscribeMessage('send')
  async handleSendChecklist(
    @ConnectedSocket() client: WebSocket,
    @MessageBody() data: string,
  ) {
    const sharedChecklistId = client['sharedChecklistId'];

    if (!sharedChecklistId)
      return { event: 'error', data: 'No sharedChecklistId provided' };

    // // 현재 sharedChecklistId에 해당하는 데이터 배열을 가져오거나 새로 생성
    // const dataForThisChecklist =
    //   this.checklistData.get(sharedChecklistId) || [];
    // dataForThisChecklist.push(data);

    // // 데이터 저장 및 브로드캐스트
    // if (dataForThisChecklist.length >= 20) {
    //   this.saveAndBroadcastData(sharedChecklistId, dataForThisChecklist, true);
    // } else {
    //   this.checklistData.set(sharedChecklistId, dataForThisChecklist);
    // }

    this.broadcastToChecklist(sharedChecklistId, 'listen', data, client);

    const serverUuid = this.serverUuid;
    const message = JSON.stringify({ serverUuid, sharedChecklistId, data });
    this.redisPublisher.publish('sharedChecklist', message);

    const redisArrayKey = `checklist:${sharedChecklistId}:array`;
    this.redisClient.rPush(redisArrayKey, data);
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
   * 데이터를 데이터베이스에 저장하고 관련 클라이언트들에게 'saved' 이벤트를 브로드캐스트한다.
   * 마지막 저장 시간을 기록한다.
   * @param sharedChecklistId 데이터를 저장할 체크리스트 ID
   * @param dataForThisChecklist 저장할 데이터 배열
   * @param broadcast 브로드캐스트 여부. 기본값은 false
   */
  private async saveAndBroadcastData(
    sharedChecklistId: string,
    dataForThisChecklist: string[],
    broadcast?: boolean,
  ) {
    const now = new Date();
    if (broadcast) {
      // this.checklistItemDate.set(sharedChecklistId, now); // 마지막 데이터 저장 시간 업데이트
      this.broadcastToChecklist(sharedChecklistId, 'saved', now.toISOString());
    }
    await this.sharedChecklistsService.createSharedChecklistItem(
      dataForThisChecklist,
      sharedChecklistId,
      now,
    );
    // this.checklistData.set(sharedChecklistId, []);
  }
}
