import { Module } from '@nestjs/common';
import { ChecklistAiService } from './checklist-ai.service';
import { ChecklistAiController } from './checklist-ai.controller';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [HttpModule],
  controllers: [ChecklistAiController],
  providers: [ChecklistAiService],
})
export class ChecklistAiModule {}
