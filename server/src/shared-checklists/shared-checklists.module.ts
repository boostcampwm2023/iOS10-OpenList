import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FoldersModule } from '../folders/folders.module';
import { UsersModule } from '../users/users.module';
import { SharedChecklistModel } from './entities/shared-checklist.entity';
import { SharedChecklistsController } from './shared-checklists.controller';
import { SharedChecklistsService } from './shared-checklists.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([SharedChecklistModel]),
    FoldersModule,
    UsersModule,
  ],
  controllers: [SharedChecklistsController],
  providers: [SharedChecklistsService],
})
export class ChecklistsModule {}
