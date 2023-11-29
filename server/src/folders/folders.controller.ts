import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { UserId } from 'src/users/decorator/userId.decorator';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FoldersService } from './folders.service';

@Controller('folders')
export class FoldersController {
  constructor(private readonly foldersService: FoldersService) {}

  @Post()
  postFolder(
    @UserId() userId: number,
    @Body() createFolderDto: CreateFolderDto,
  ) {
    return this.foldersService.createFolder(userId, createFolderDto);
  }

  @Get()
  getFolders(@UserId() userId: number) {
    return this.foldersService.findAllFolders(userId);
  }

  @Get(':folderId')
  getFolder(@Param('folderId') folderId: number, @UserId() userId: number) {
    return this.foldersService.findFolderById(folderId, userId);
  }

  @Put(':folderId')
  putFolder(
    @Param('folderId') folderId: number,
    @UserId() userId: number,
    @Body() updateFolderDto: UpdateFolderDto,
  ) {
    return this.foldersService.updateFolder(folderId, userId, updateFolderDto);
  }

  @Delete(':folderId')
  deleteFolder(@Param('folderId') folderId: number, @UserId() userId: number) {
    return this.foldersService.removeFolder(folderId, userId);
  }
}
