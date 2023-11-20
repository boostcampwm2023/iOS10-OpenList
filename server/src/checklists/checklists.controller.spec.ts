import { Test, TestingModule } from '@nestjs/testing';
import { PrivateChecklistsController } from './private-checklists.controller';
import { PrivateChecklistsService } from './private-checklists.service';

describe('ChecklistsController', () => {
  let controller: PrivateChecklistsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PrivateChecklistsController],
      providers: [PrivateChecklistsService],
    }).compile();

    controller = module.get<PrivateChecklistsController>(
      PrivateChecklistsController,
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
