import { Test, TestingModule } from '@nestjs/testing';
import { ShareChecklistSocketService } from './share-checklist-socket.service';

describe('ShareChecklistSocketService', () => {
  let service: ShareChecklistSocketService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ShareChecklistSocketService],
    }).compile();

    service = module.get<ShareChecklistSocketService>(ShareChecklistSocketService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
