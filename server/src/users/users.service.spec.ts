import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { TestCommonModule } from 'test/test-common.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModel } from './entities/user.entity';

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UsersService],
      imports: [TestCommonModule, TypeOrmModule.forFeature([UsersModel])],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
