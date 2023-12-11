import { ChecklistAiService } from './checklist-ai.service';
import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { CreateChecklistItemsDto } from './dto/create-checklist-items.dto';

@Controller('checklist-ai')
export class ChecklistAiController {
  constructor(private readonly checklistAiService: ChecklistAiService) {}

  @Post()
  async getChecklistItemsWithAi(@Body() dto: CreateChecklistItemsDto) {
    return this.checklistAiService.generateChecklistItemWithAi(dto);
  }

  @Get('count-item')
  async getAiItemCount() {
    return this.checklistAiService.publishToCountItemsByCategory();
  }

  // query param으로 count 가지고 옴.
  @Post('generate-item')
  async postAiItemGenerate(@Query('count') count: number) {
    return this.checklistAiService.publishToGenerateItemsLessThanCount(count);
  }
}
