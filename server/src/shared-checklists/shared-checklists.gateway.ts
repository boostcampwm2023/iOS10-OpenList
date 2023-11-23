import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { parse } from 'url';
import * as WebSocket from 'ws';

/**
 * 웹소켓 통신을 통해 클라이언트들의 체크리스트 공유를 관리하는 게이트웨이.
 */
@WebSocketGateway({ path: '/share-checklist' })
export class SharedChecklistsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer() server: WebSocket.Server;

  // 각 checklist ID별로 연결된 클라이언트들을 추적하기 위한 맵
  private clients: Map<string, Set<WebSocket>> = new Map();

  /**
   * 클라이언트가 연결을 시도할 때 호출되는 메서드.
   * 연결된 클라이언트에 sharedChecklistId를 할당하고 관리한다.
   * @param client 연결된 클라이언트의 웹소켓 객체
   */
  handleConnection(@ConnectedSocket() client: WebSocket, ...args: any[]) {
    const request = args[0];
    const { query } = parse(request.url, true);
    const sharedChecklistId = query.cid as string;

    // 클라이언트에 할당된 sharedChecklistId를 바탕으로 클라이언트 관리
    if (sharedChecklistId) {
      client['sharedChecklistId'] = sharedChecklistId;
      if (!this.clients.has(sharedChecklistId)) {
        this.clients.set(sharedChecklistId, new Set());
      }
      this.clients.get(sharedChecklistId)?.add(client);
    }
  }

  /**
   * 클라이언트 연결이 해제될 때 호출되는 메서드.
   * 해당 클라이언트를 관리 목록에서 제거한다.
   * @param client 연결 해제된 클라이언트의 웹소켓 객체
   */
  handleDisconnect(@ConnectedSocket() client: WebSocket) {
    const sharedChecklistId = client['sharedChecklistId'];
    if (sharedChecklistId && this.clients.has(sharedChecklistId)) {
      const clientsSet = this.clients.get(sharedChecklistId);
      clientsSet?.delete(client);
      // 더 이상 해당 sharedChecklistId에 연결된 클라이언트가 없으면 맵에서 제거
      if (clientsSet?.size === 0) {
        this.clients.delete(sharedChecklistId);
      }
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
    excludeClient: WebSocket,
  ) {
    const clients = this.clients.get(sharedChecklistId);
    if (clients) {
      clients.forEach((client) => {
        if (client !== excludeClient && client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({ event, data }));
        }
      });
    }
  }

  /**
   * 'sendChecklist' 이벤트를 처리하고, 해당 sharedChecklistId를 가진 다른 클라이언트들에게
   * 'listenChecklist' 이벤트를 브로드캐스트한다.
   * @param client 메시지를 보낸 클라이언트의 웹소켓 객체
   * @param data 클라이언트로부터 받은 데이터
   * @returns 이벤트 처리 결과를 나타내는 객체
   */
  @SubscribeMessage('sendChecklist')
  async handleSendChecklist(
    @ConnectedSocket() client: WebSocket,
    @MessageBody() data: string,
  ) {
    const sharedChecklistId = client['sharedChecklistId'];
    if (sharedChecklistId) {
      this.broadcastToChecklist(
        sharedChecklistId,
        'listenChecklist',
        data,
        client,
      );
    }
    return { event: 'sendChecklist', data: data };
  }
}
