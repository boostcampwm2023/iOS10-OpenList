import { Controller } from '@nestjs/common';
import { ChecklistAiService } from './checklist-ai.service';

@Controller('checklist-ai')
export class ChecklistAiController {
  constructor(private readonly checklistAiService: ChecklistAiService) {}
}
