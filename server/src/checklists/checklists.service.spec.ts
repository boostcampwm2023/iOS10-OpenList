import { Test, TestingModule } from '@nestjs/testing';
import { ChecklistsService } from './checklists.service';

describe('ChecklistsService', () => {
  let service: ChecklistsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ChecklistsService],
    }).compile();

    service = module.get<ChecklistsService>(ChecklistsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
