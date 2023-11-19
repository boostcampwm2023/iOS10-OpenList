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
    return this.foldersService.createFolder(createFolderDto);
  }

  @Get()
  getFolders() {
    return this.foldersService.findAllFolders();
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
