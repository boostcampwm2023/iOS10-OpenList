import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ProviderType, UserModel } from './entities/user.entity';
import { UsersService } from './users.service';

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('UsersService', () => {
  let service: UsersService;
  let mockUsersRepository: MockRepository<UserModel>;

  beforeEach(async () => {
    mockUsersRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      remove: jest.fn(),
      exist: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(UserModel),
          useValue: mockUsersRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('service.createUser(createUserDto) : 새로운 유저를 생성한다.', async () => {
    const createUserDto: CreateUserDto = {
      email: 'test@example.com',
      fullName: 'TestUser',
      providerId: '1234567890',
      provider: ProviderType.APPLE, // Enum 멤버 사용
    };
    mockUsersRepository.exist.mockResolvedValue(false);
    mockUsersRepository.create.mockReturnValue(createUserDto);
    mockUsersRepository.save.mockResolvedValue({ userId: 1, ...createUserDto });

    const result = await service.createUser(createUserDto);

    expect(mockUsersRepository.exist).toHaveBeenCalledWith({
      where: { email: createUserDto.email },
    });
    expect(mockUsersRepository.create).toHaveBeenCalledWith(createUserDto);
    expect(mockUsersRepository.save).toHaveBeenCalledWith(createUserDto);
    expect(result).toEqual({ userId: 1, ...createUserDto });
  });

  it('service.createUser(createUserDto) : 이미 존재하는 이메일일 경우 BadRequestException을 던진다.', async () => {
    const createUserDto: CreateUserDto = {
      email: 'test@example.com',
      fullName: 'TestUser',
      providerId: '1234567890',
      provider: ProviderType.APPLE, // Enum 멤버 사용
    };
    mockUsersRepository.exist.mockResolvedValue(true);

    await expect(service.createUser(createUserDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.findAllUsers() : 모든 유저를 찾는다.', async () => {
    const mockUsers = [
      { userId: 1, email: 'test@example.com', nickname: 'TestUser' },
      { userId: 2, email: 'test2@example.com', nickname: 'TestUser2' },
    ];
    mockUsersRepository.find.mockResolvedValue(mockUsers);

    const result = await service.findAllUsers();

    expect(mockUsersRepository.find).toHaveBeenCalled();
    expect(result).toEqual(mockUsers);
  });

  it('service.findUserById(userId) : userId에 해당하는 유저를 찾는다.', async () => {
    const user = { userId: 1, email: 'test@example.com', nickname: 'TestUser' };
    mockUsersRepository.findOne.mockResolvedValue(user);

    const result = await service.findUserById(1);

    expect(mockUsersRepository.findOne).toHaveBeenCalledWith({
      where: { userId: 1 },
    });
    expect(result).toEqual(user);
  });

  it('service.findUserById(userId) : 존재하지 않는 유저일 경우 BadRequestException을 던진다.', async () => {
    mockUsersRepository.findOne.mockResolvedValue(null);

    await expect(service.findUserById(1)).rejects.toThrow(BadRequestException);
  });

  it('service.updateUser(userId, updateUserDto) : userId에 해당하는 유저를 업데이트한다.', async () => {
    const updateUserDto: UpdateUserDto = { fullName: 'UpdatedUser' };
    const existingUser = {
      userId: 1,
      email: 'test@example.com',
      fullName: 'TestUser',
    };
    mockUsersRepository.findOne.mockResolvedValue(existingUser);
    mockUsersRepository.save.mockResolvedValue({
      ...existingUser,
      ...updateUserDto,
    });

    const result = await service.updateUser(1, updateUserDto);

    expect(mockUsersRepository.findOne).toHaveBeenCalledWith({
      where: { userId: 1 },
    });
    expect(mockUsersRepository.save).toHaveBeenCalledWith({
      ...existingUser,
      ...updateUserDto,
    });
    expect(result.fullName).toEqual('UpdatedUser');
  });

  it('service.updateUser(userId, updateUserDto) : 존재하지 않는 유저일 경우 BadRequestException을 던진다.', async () => {
    const updateUserDto: UpdateUserDto = { fullName: 'UpdatedUser' };
    mockUsersRepository.findOne.mockResolvedValue(null);

    await expect(service.updateUser(1, updateUserDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.removeUser(userId) : userId에 해당하는 유저를 삭제한다.', async () => {
    const user = { userId: 1, email: 'test@example.com', nickname: 'TestUser' };
    mockUsersRepository.findOne.mockResolvedValue(user);
    mockUsersRepository.remove.mockResolvedValue(user);

    const result = await service.removeUser(1);

    expect(mockUsersRepository.findOne).toHaveBeenCalledWith({
      where: { userId: 1 },
    });
    expect(mockUsersRepository.remove).toHaveBeenCalledWith(user);
    expect(result).toEqual({ message: '삭제되었습니다.' });
  });

  it('service.removeUser(userId) : 존재하지 않는 유저일 경우 BadRequestException을 던진다.', async () => {
    mockUsersRepository.findOne.mockResolvedValue(null);
    await expect(service.removeUser(1)).rejects.toThrow(BadRequestException);
  });
});
