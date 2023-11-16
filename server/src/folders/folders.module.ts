import { Module } from '@nestjs/common';
import { FoldersService } from './folders.service';
import { FoldersController } from './folders.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FolderModel } from './entities/folder.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FolderModel])],
  controllers: [FoldersController],
  providers: [FoldersService],
})
export class FoldersModule {}
