import { Module } from '@nestjs/common';
import { ShareChecklistSocketService } from './share-checklist-socket.service';
import { ShareChecklistSocketGateway } from './share-checklist-socket.gateway';

@Module({
  providers: [ShareChecklistSocketGateway, ShareChecklistSocketService],
})
export class ShareChecklistSocketModule {}
