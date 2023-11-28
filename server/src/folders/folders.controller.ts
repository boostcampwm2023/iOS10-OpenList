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

  @Get(':forderId')
  getFolder(@Param('forderId') forderId: number, @UserId() userId: number) {
    return this.foldersService.findFolderById(forderId, userId);
  }

  @Put(':forderId')
  putFolder(
    @Param('forderId') forderId: number,
    @UserId() userId: number,
    @Body() updateFolderDto: UpdateFolderDto,
  ) {
    return this.foldersService.updateFolder(forderId, userId, updateFolderDto);
  }

  @Delete(':forderId')
  deleteFolder(@Param('forderId') forderId: number, @UserId() userId: number) {
    return this.foldersService.removeFolder(forderId, userId);
  }
}
