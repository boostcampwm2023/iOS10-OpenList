import { Test, TestingModule } from '@nestjs/testing';
import { FoldersService } from './folders.service';
import { FolderModel } from './entities/folder.entity';
import { Repository } from 'typeorm';
import { BadRequestException } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('FoldersService', () => {
  let service: FoldersService;
  let mockFoldersRepository: MockRepository<FolderModel>;

  beforeEach(async () => {
    mockFoldersRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      remove: jest.fn(),
      exist: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FoldersService,
        {
          provide: getRepositoryToken(FolderModel),
          useValue: mockFoldersRepository,
        },
      ],
    }).compile();

    service = module.get<FoldersService>(FoldersService);
  });

  it('service.createFolder(createFolderDto) : 새로운 폴더를 생성한다.', async () => {
    const createFolderDto: CreateFolderDto = {
      title: 'blackpink in your area',
    };
    mockFoldersRepository.exist.mockResolvedValue(false);
    mockFoldersRepository.create.mockReturnValue(createFolderDto);
    mockFoldersRepository.save.mockResolvedValue({ id: 1, ...createFolderDto });

    const result = await service.createFolder(createFolderDto);

    expect(mockFoldersRepository.exist).toHaveBeenCalledWith({
      where: { title: createFolderDto.title },
    });
    expect(mockFoldersRepository.create).toHaveBeenCalledWith(createFolderDto);
    expect(mockFoldersRepository.save).toHaveBeenCalledWith(createFolderDto);
    expect(result).toEqual({ id: 1, ...createFolderDto });
  });

  it('service.createFolder(createFolderDto) : 이미 존재하는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    const createFolderDto: CreateFolderDto = {
      title: 'blackpink in your area',
    };
    mockFoldersRepository.exist.mockResolvedValue(true);

    await expect(service.createFolder(createFolderDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.findAllFolders() : 모든 폴더를 찾는다.', async () => {
    const mockFolders = [
      { id: 1, email: 'test@example.com', nickname: 'TestFolder' },
      { id: 2, email: 'test2@example.com', nickname: 'TestFolder2' },
    ];
    mockFoldersRepository.find.mockResolvedValue(mockFolders);

    const result = await service.findAllFolders();

    expect(mockFoldersRepository.find).toHaveBeenCalled();
    expect(result).toEqual(mockFolders);
  });

  it('service.findFolderById(id) : id에 해당하는 폴더를 찾는다.', async () => {
    const folder = { id: 1, title: 'blackpink in your area' };
    mockFoldersRepository.findOne.mockResolvedValue(folder);

    const result = await service.findFolderById(1);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { id: 1 },
    });
    expect(result).toEqual(folder);
  });

  it('service.findFolderById(id) : 존재하지 않는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    mockFoldersRepository.findOne.mockResolvedValue(null);

    await expect(service.findFolderById(1)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.updateFolder(id, updateFolderDto) : id에 해당하는 폴더를 업데이트한다.', async () => {
    const updateFolderDto: UpdateFolderDto = {
      title: 'newJeans in your area',
    };
    const existingFolder = {
      id: 1,
      title: 'blackpink in your area',
    };
    mockFoldersRepository.findOne.mockResolvedValue(existingFolder);
    mockFoldersRepository.save.mockResolvedValue({
      ...existingFolder,
      ...updateFolderDto,
    });

    const result = await service.updateFolder(1, updateFolderDto);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { id: 1 },
    });
    expect(mockFoldersRepository.save).toHaveBeenCalledWith({
      ...existingFolder,
      ...updateFolderDto,
    });
    expect(result.title).toEqual('newJeans in your area');
  });

  it('service.updateFolder(id, updateFolderDto) : 존재하지 않는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    const updateFolderDto: UpdateFolderDto = { title: 'UpdatedFolder' };
    mockFoldersRepository.findOne.mockResolvedValue(null);

    await expect(service.updateFolder(1, updateFolderDto)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.removeFolder(id) : id에 해당하는 폴더를 삭제한다.', async () => {
    const folder = { id: 1, title: 'blackpink in your area' };
    mockFoldersRepository.findOne.mockResolvedValue(folder);
    mockFoldersRepository.remove.mockResolvedValue(folder);

    const result = await service.removeFolder(1);

    expect(mockFoldersRepository.findOne).toHaveBeenCalledWith({
      where: { id: 1 },
    });
    expect(mockFoldersRepository.remove).toHaveBeenCalledWith(folder);
    expect(result).toEqual({ message: '삭제되었습니다.' });
  });

  it('service.removeFolder(id) : 존재하지 않는 폴더명일 경우 BadRequestException을 던진다.', async () => {
    mockFoldersRepository.findOne.mockResolvedValue(null);
    await expect(service.removeFolder(1)).rejects.toThrow(BadRequestException);
  });
});