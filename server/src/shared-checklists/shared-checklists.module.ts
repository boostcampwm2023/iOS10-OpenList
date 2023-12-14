import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FoldersModule } from '../folders/folders.module';
import { UsersModule } from '../users/users.module';
import { SharedChecklistItemModel } from './entities/shared-checklist-item.entity';
import { SharedChecklistModel } from './entities/shared-checklist.entity';
import { SharedChecklistsController } from './shared-checklists.controller';
import { SharedChecklistsGateway } from './shared-checklists.gateway';
import { SharedChecklistsService } from './shared-checklists.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([SharedChecklistModel, SharedChecklistItemModel]),
    FoldersModule,
    UsersModule,
  ],
  controllers: [SharedChecklistsController],
  providers: [SharedChecklistsService, SharedChecklistsGateway],
})
export class SharedChecklistsModule {}
