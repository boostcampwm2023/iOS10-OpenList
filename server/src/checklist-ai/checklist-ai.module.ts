import { Module } from '@nestjs/common';
import { ChecklistAiService } from './checklist-ai.service';
import { ChecklistAiController } from './checklist-ai.controller';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiChecklistItemModel } from './entities/ai-checklist-item';
import { AiChecklistItemNaverReasonModel } from './entities/ai-checklist-item-naver-reason.entity';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([
      AiChecklistItemModel,
      AiChecklistItemNaverReasonModel,
    ]),
  ],
  controllers: [ChecklistAiController],
  providers: [ChecklistAiService],
})
export class ChecklistAiModule {}
