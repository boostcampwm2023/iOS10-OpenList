import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FoldersService } from './folders.service';

@Controller('folders')
export class FoldersController {
  constructor(private readonly foldersService: FoldersService) {}

  @Post()
  postFolder(@Body() createFolderDto: CreateFolderDto) {
    const userId: number = 1;
    return this.foldersService.createFolder(userId, createFolderDto);
  }

  @Get()
  getFolders() {
    const userId: number = 1;
    return this.foldersService.findAllFolders(userId);
  }

  @Get(':forderId')
  getFolder(@Param('forderId') forderId: number) {
    return this.foldersService.findFolderById(forderId);
  }

  @Put(':forderId')
  putFolder(
    @Param('forderId') forderId: number,
    @Body() updateFolderDto: UpdateFolderDto,
  ) {
    return this.foldersService.updateFolder(forderId, updateFolderDto);
  }

  @Delete(':forderId')
  deleteFolder(@Param('forderId') forderId: number) {
    return this.foldersService.removeFolder(forderId);
  }
}
