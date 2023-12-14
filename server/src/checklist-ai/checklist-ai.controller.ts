import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  UnauthorizedException,
} from '@nestjs/common';
import { UserId } from 'src/users/decorator/userId.decorator';
import { ChecklistAiService } from './checklist-ai.service';
import { CreateChecklistItemsDto } from './dto/create-checklist-items.dto';

@Controller('checklist-ai')
export class ChecklistAiController {
  constructor(private readonly checklistAiService: ChecklistAiService) {}

  @Post()
  async getChecklistItemsWithAi(@Body() dto: CreateChecklistItemsDto) {
    return this.checklistAiService.findAiChecklistItems(dto);
  }

  @Get('count-item')
  async getAiItemCount(@UserId() userId: number) {
    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }
    return this.checklistAiService.publishToCountItemsByCategory();
  }

  // query param으로 count 가지고 옴.
  @Post('generate-item')
  async postAiItemGenerate(
    @Query('count') count: number,
    @UserId() userId: number,
  ) {
    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }
    return this.checklistAiService.publishToGenerateItemsLessThanCount(count);
  }

  @Post('evaluate-item')
  async postAiItemEvaluate(
    @Query('count') count: number,
    @UserId() userId: number,
  ) {
    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }
    return this.checklistAiService.publishToEvaluateItems(count);
  }
}
