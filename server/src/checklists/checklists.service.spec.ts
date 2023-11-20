import { Test, TestingModule } from '@nestjs/testing';
import { PrivateChecklistsService } from './private-checklists.service';

describe('ChecklistsService', () => {
  let service: PrivateChecklistsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PrivateChecklistsService],
    }).compile();

    service = module.get<PrivateChecklistsService>(PrivateChecklistsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
