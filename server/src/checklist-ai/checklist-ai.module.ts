import { Module } from '@nestjs/common';
import { ChecklistAiService } from './checklist-ai.service';
import { ChecklistAiController } from './checklist-ai.controller';

@Module({
  controllers: [ChecklistAiController],
  providers: [ChecklistAiService],
})
export class ChecklistAiModule {}
