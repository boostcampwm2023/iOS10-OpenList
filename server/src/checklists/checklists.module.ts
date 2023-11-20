import { Module } from '@nestjs/common';
import { PrivateChecklistsService } from './private-checklists.service';
import { PrivateChecklistsController } from './private-checklists.controller';
import { SharedChecklistsController } from './shared-checklists.controller';
import { SharedChecklistsService } from './shared-checklists.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PrivateChecklistModel } from './entities/private-checklist.entity';
import { SharedChecklistModel } from './entities/shared-checklist.entity';
import { FoldersModule } from '../folders/folders.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([PrivateChecklistModel, SharedChecklistModel]),
    FoldersModule,
    UsersModule,
  ],
  controllers: [PrivateChecklistsController, SharedChecklistsController],
  providers: [PrivateChecklistsService, SharedChecklistsService],
})
export class ChecklistsModule {}
