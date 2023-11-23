import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import * as WebSocket from 'ws';

import { CreateShareChecklistSocketDto } from './dto/create-share-checklist-socket.dto';

/**
 * 클라이언트 연결, 연결 해제, 메시지 송수신을 처리하는 웹소켓 게이트웨이.
 */
@WebSocketGateway()
export class ShareChecklistSocketGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer() server: WebSocket.Server;

  private clients: Set<WebSocket> = new Set(); // 현재 연결된 모든 클라이언트를 추적하는 집합

  constructor() {}

  /**
   * 새로운 클라이언트가 연결될 때 실행되는 메서드.
   * 클라이언트의 IP 주소를 로깅하고 클라이언트 집합에 추가한다.
   * @param client 연결된 클라이언트의 웹소켓 객체
   */
  handleConnection(client: WebSocket, ...args: any[]) {
    const clientIp = client['_socket'].remoteAddress;
    console.log(`Client connected: ${clientIp}`);
    this.clients.add(client);
  }

  /**
   * 클라이언트 연결이 해제될 때 실행되는 메서드.
   * 클라이언트의 IP 주소를 로깅하고 클라이언트 집합에서 제거한다.
   * @param client 연결이 해제된 클라이언트의 웹소켓 객체
   */
  handleDisconnect(client: WebSocket) {
    const clientIp = client['_socket'].remoteAddress;
    console.log(`Client disconnected: ${clientIp}`);
    this.clients.delete(client);
  }

  /**
   * 지정된 이벤트로 모든 클라이언트에게 데이터를 브로드캐스트한다.
   * 메시지를 보낸 클라이언트는 제외된다.
   * @param event 브로드캐스트할 이벤트 이름
   * @param data 전송할 데이터
   * @param excludeClient 브로드캐스트에서 제외할 클라이언트
   */
  private broadcast(event: string, data: any, excludeClient: WebSocket) {
    for (const client of this.clients) {
      if (client !== excludeClient && client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ event, data }));
      }
    }
  }

  /**
   * 'sendChecklist' 이벤트를 처리하여, 본인을 제외한 다른 클라이언트에게
   * 'listenChecklist' 이벤트로 데이터를 브로드캐스트한다.
   * @param client 메시지를 보낸 클라이언트의 웹소켓 객체
   * @param data 클라이언트로부터 받은 데이터
   * @returns 처리 결과를 나타내는 객체
   */
  @SubscribeMessage('sendChecklist')
  async handleSendChecklist(
    client: WebSocket,
    data: CreateShareChecklistSocketDto,
  ) {
    this.broadcast('listenChecklist', data, client);
    return { event: 'sendChecklist', data: data };
  }
}
