import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FoldersModule } from '../folders/folders.module';
import { UsersModule } from '../users/users.module';
import { PrivateChecklistModel } from './entities/private-checklist.entity';
import { PrivateChecklistsController } from './private-checklists.controller';
import { PrivateChecklistsService } from './private-checklists.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([PrivateChecklistModel]),
    FoldersModule,
    UsersModule,
  ],
  controllers: [PrivateChecklistsController],
  providers: [PrivateChecklistsService],
})
export class ChecklistsModule {}
