import { Test, TestingModule } from '@nestjs/testing';
import { ChecklistAiService } from './checklist-ai.service';

describe('ChecklistAiService', () => {
  let service: ChecklistAiService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ChecklistAiService],
    }).compile();

    service = module.get<ChecklistAiService>(ChecklistAiService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
