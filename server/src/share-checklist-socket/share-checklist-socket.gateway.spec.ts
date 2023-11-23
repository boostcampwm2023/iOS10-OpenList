import { Test, TestingModule } from '@nestjs/testing';
import { ShareChecklistSocketGateway } from './share-checklist-socket.gateway';
import { ShareChecklistSocketService } from './share-checklist-socket.service';

describe('ShareChecklistSocketGateway', () => {
  let gateway: ShareChecklistSocketGateway;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ShareChecklistSocketGateway, ShareChecklistSocketService],
    }).compile();

    gateway = module.get<ShareChecklistSocketGateway>(ShareChecklistSocketGateway);
  });

  it('should be defined', () => {
    expect(gateway).toBeDefined();
  });
});
