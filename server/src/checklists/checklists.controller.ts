import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { ChecklistsService } from './checklists.service';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';

@Controller('checklists')
export class ChecklistsController {
  constructor(private readonly checklistsService: ChecklistsService) {}

  @Post()
  create(@Body() createChecklistDto: CreatePrivateChecklistDto) {
    return this.checklistsService.create(createChecklistDto);
  }

  @Get()
  findAll() {
    return this.checklistsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.checklistsService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateChecklistDto: UpdatePrivateChecklistDto,
  ) {
    return this.checklistsService.update(+id, updateChecklistDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.checklistsService.remove(+id);
  }
}
