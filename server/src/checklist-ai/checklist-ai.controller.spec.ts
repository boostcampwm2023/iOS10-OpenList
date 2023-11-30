import { Test, TestingModule } from '@nestjs/testing';
import { ChecklistAiController } from './checklist-ai.controller';
import { ChecklistAiService } from './checklist-ai.service';

describe('ChecklistAiController', () => {
  let controller: ChecklistAiController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ChecklistAiController],
      providers: [ChecklistAiService],
    }).compile();

    controller = module.get<ChecklistAiController>(ChecklistAiController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
