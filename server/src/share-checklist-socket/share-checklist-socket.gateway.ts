import {
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';

import { CreateShareChecklistSocketDto } from './dto/create-share-checklist-socket.dto';
import { UpdateShareChecklistSocketDto } from './dto/update-share-checklist-socket.dto';
import { ShareChecklistSocketService } from './share-checklist-socket.service';

@WebSocketGateway()
export class ShareChecklistSocketGateway {
  constructor(
    private readonly shareChecklistSocketService: ShareChecklistSocketService,
  ) {}

  @SubscribeMessage('createShareChecklistSocket')
  create(
    @MessageBody() createShareChecklistSocketDto: CreateShareChecklistSocketDto,
  ) {
    return this.shareChecklistSocketService.create(
      createShareChecklistSocketDto,
    );
  }

  @SubscribeMessage('findAllShareChecklistSocket')
  findAll() {
    return this.shareChecklistSocketService.findAll();
  }

  @SubscribeMessage('findOneShareChecklistSocket')
  findOne(@MessageBody() id: number) {
    return this.shareChecklistSocketService.findOne(id);
  }

  @SubscribeMessage('updateShareChecklistSocket')
  update(
    @MessageBody() updateShareChecklistSocketDto: UpdateShareChecklistSocketDto,
  ) {
    return this.shareChecklistSocketService.update(
      updateShareChecklistSocketDto.id,
      updateShareChecklistSocketDto,
    );
  }

  @SubscribeMessage('removeShareChecklistSocket')
  remove(@MessageBody() id: number) {
    return this.shareChecklistSocketService.remove(id);
  }
}
