import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserModel } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderModel } from './entities/folder.entity';
import { FoldersService } from './folders.service';

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('FoldersService', () => {
  let service: FoldersService;
  let mockFoldersRepository: MockRepository<FolderModel>;
  let mockUsersRepository: MockRepository<UserModel>;

  beforeEach(async () => {
    mockFoldersRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      remove: jest.fn(),
      exist: jest.fn(),
    };

    mockUsersRepository = {
      findOne: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FoldersService,
        UsersService,
        {
          provide: getRepositoryToken(FolderModel),
          useValue: mockFoldersRepository,
        },
        {
          provide: getRepositoryToken(UserModel),
          useValue: mockUsersRepository,
        },
      ],
    }).compile();

    service = module.get<FoldersService>(FoldersService);
  });

  it('service.createFolder(createFolderDto) : 새로운 폴더를 생성한다.', async () => {
    const createFolderDto: CreateFolderDto = {
      title: 'blackpink in your area',
    };
    const user = new UserModel(); // 새로운 UserModel 인스턴스 생성
    mockUsersRepository.findOne.mockResolvedValue(user); // 존재하는 사용자를 반환
    mockFoldersRepository.exist.mockResolvedValue(false);

    // createFolderDto와 owner를 포함한 객체를 create 메서드에 전달
    const expectedFolderObject = {
      ...createFolderDto,
      owner: user,
    };
    mockFoldersRepository.create.mockReturnValue(expectedFolderObject);
    mockFoldersRepository.save.mockResolvedValue({
      folderId: 1,
      ...expectedFolderObject,
    });

    const result = await service.createFolder(1, createFolderDto);

    expect(mockFoldersRepository.exist).toHaveBeenCalledWith({
      where: { title: createFolderDto.title },
    });
    expect(mockFoldersRepository.create).toHaveBeenCalledWith(
      expectedFolderObject,
    ); // 수정된 부분
    expect(mockFoldersRepository.save).toHaveBeenCalledWith(
      expectedFolderObject,
    ); // 수정된 부분
    expect(result).toEqual({ folderId: 1, ...expectedFolderObject });
  });

  it('service.createFolder(createFolderDto) : 이미 존재하는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    const createFolderDto: CreateFolderDto = {
      title: 'blackpink in your area',
    };
    mockUsersRepository.findOne.mockResolvedValue(new UserModel()); // 존재하는 사용자를 반환
    mockFoldersRepository.exist.mockResolvedValue(true);

    await expect(service.createFolder(1, createFolderDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.createFolder(createFolderDto) : 존재하지 않는 사용자일 경우 BadRequestException을 던진다.', async () => {
    const createFolderDto: CreateFolderDto = {
      title: 'new folder',
    };
    mockUsersRepository.findOne.mockResolvedValue(null); // 존재하지 않는 사용자를 반환

    await expect(service.createFolder(1, createFolderDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.findAllFolders() : 모든 폴더를 찾는다.', async () => {
    const mockFolders = [
      { folderId: 1, email: 'test@example.com', nickname: 'TestFolder' },
      { folderId: 2, email: 'test2@example.com', nickname: 'TestFolder2' },
    ];
    mockFoldersRepository.find.mockResolvedValue(mockFolders);

    const result = await service.findAllFolders(1);

    expect(mockFoldersRepository.find).toHaveBeenCalled();
    expect(result).toEqual(mockFolders);
  });

  it('service.findFolderById(id) : folderId에 해당하는 폴더를 찾는다.', async () => {
    const folder = { folderId: 1, title: 'blackpink in your area' };
    mockFoldersRepository.findOne.mockResolvedValue(folder);

    const result = await service.findFolderById(1, 1);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { folderId: 1 },
      relations: ['owner'],
    });
    expect(result).toEqual(folder);
  });

  it('service.findFolderById(folderId) : 존재하지 않는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    mockFoldersRepository.findOne.mockResolvedValue(null);

    await expect(service.findFolderById(1, 1)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.updateFolder(folderId, updateFolderDto) : folderId에 해당하는 폴더를 업데이트한다.', async () => {
    const updateFolderDto: UpdateFolderDto = {
      title: 'newJeans in your area',
    };
    const existingFolder = {
      folderId: 1,
      title: 'blackpink in your area',
    };
    mockFoldersRepository.findOne.mockResolvedValue(existingFolder);
    mockFoldersRepository.save.mockResolvedValue({
      ...existingFolder,
      ...updateFolderDto,
    });

    const result = await service.updateFolder(1, 1, updateFolderDto);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { folderId: 1 },
      relations: ['owner'],
    });
    expect(mockFoldersRepository.save).toHaveBeenCalledWith({
      ...existingFolder,
      ...updateFolderDto,
    });
    expect(result.title).toEqual('newJeans in your area');
  });

  it('service.updateFolder(folderId, updateFolderDto) : 존재하지 않는 폴더 ID에 대한 처리를 검증한다.', async () => {
    const updateFolderDto: UpdateFolderDto = { title: 'UpdatedFolder' };
    mockFoldersRepository.findOne.mockResolvedValueOnce(null); // 폴더가 존재하지 않는다고 가정

    await expect(
      service.updateFolder(9999, 1, updateFolderDto),
    ).rejects.toThrow(BadRequestException);
  });

  it('service.removeFolder(folderId) : folderId에 해당하는 폴더를 삭제한다.', async () => {
    const folder = { folderId: 1, title: 'blackpink in your area' };
    mockFoldersRepository.findOne.mockResolvedValue(folder);
    mockFoldersRepository.remove.mockResolvedValue(folder);

    const result = await service.removeFolder(1, 1);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { folderId: 1 },
      relations: ['owner'],
    });
    expect(mockFoldersRepository.remove).toHaveBeenCalledWith(folder);
    expect(result).toEqual({ message: '삭제되었습니다.' });
  });

  it('service.removeFolder(folderId) : 존재하지 않는 폴더 ID에 대한 처리를 검증한다.', async () => {
    mockFoldersRepository.findOne.mockResolvedValueOnce(null); // 폴더가 존재하지 않는다고 가정

    await expect(service.removeFolder(9999, 1)).rejects.toThrow(
      BadRequestException,
    );
  });
});
