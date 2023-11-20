import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
} from '@nestjs/common';
import { FoldersService } from './folders.service';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';

@Controller('folders')
export class FoldersController {
  constructor(private readonly foldersService: FoldersService) {}

  @Post()
  postFolder(@Body() createFolderDto: CreateFolderDto) {
    const uId = 1;
    return this.foldersService.createFolder(uId, createFolderDto);
  }

  @Get()
  getFolders() {
    const uId = 1;
    return this.foldersService.findAllFolders(uId);
  }

  @Get(':id')
  getFolder(@Param('id') id: number) {
    return this.foldersService.findFolderById(id);
  }

  @Put(':id')
  putFolder(@Param('id') id: number, @Body() updateFolderDto: UpdateFolderDto) {
    return this.foldersService.updateFolder(id, updateFolderDto);
  }

  @Delete(':id')
  deleteFolder(@Param('id') id: number) {
    return this.foldersService.removeFolder(id);
  }
}
