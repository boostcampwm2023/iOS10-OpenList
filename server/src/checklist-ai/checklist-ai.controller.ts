import { ChecklistAiService } from './checklist-ai.service';
import { Body, Controller, Post } from '@nestjs/common';
import { CreateChecklistItemsDto } from './dto/create-checklist-items.dto';

@Controller('checklist-ai')
export class ChecklistAiController {
  constructor(private readonly checklistAiService: ChecklistAiService) {}

  @Post()
  async getChecklistItemsWithAi(@Body() dto: CreateChecklistItemsDto) {
    return this.checklistAiService.generateChecklistItemWithAi(dto);
  }
}
