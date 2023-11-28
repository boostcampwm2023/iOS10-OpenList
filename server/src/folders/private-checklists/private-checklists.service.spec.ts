import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserModel } from '../../users/entities/user.entity';
import { UsersService } from '../../users/users.service';
import { FolderModel } from '../entities/folder.entity';
import { FoldersService } from '../folders.service';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';
import { PrivateChecklistModel } from './entities/private-checklist.entity';
import { PrivateChecklistsService } from './private-checklists.service';

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('PrivateChecklistsService', () => {
  let service: PrivateChecklistsService;
  let mockChecklistRepository: MockRepository<PrivateChecklistModel>;
  let mockFoldersService: Partial<FoldersService>;
  let mockUsersService: Partial<UsersService>;
  let mockFoldersRepository: MockRepository<FolderModel>;
  let mockUsersRepository: MockRepository<UserModel>;

  beforeEach(async () => {
    mockChecklistRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      remove: jest.fn(),
    };

    mockUsersService = {
      findUserById: jest.fn().mockResolvedValue(new UserModel()),
    };

    mockFoldersService = {
      findFolderById: jest.fn().mockResolvedValue(new FolderModel()),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PrivateChecklistsService,
        FoldersService,
        UsersService,
        {
          provide: getRepositoryToken(PrivateChecklistModel),
          useValue: mockChecklistRepository,
        },
        {
          provide: getRepositoryToken(FolderModel),
          useValue: mockFoldersRepository,
        },
        {
          provide: getRepositoryToken(UserModel),
          useValue: mockUsersRepository,
        },
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
        {
          provide: FoldersService,
          useValue: mockFoldersService,
        },
      ],
    }).compile();

    service = module.get<PrivateChecklistsService>(PrivateChecklistsService);
  });

  it('service.createPrivateChecklist(createPrivateChecklistDto) : 새로운 체크리스트를 생성한다.', async () => {
    const user = new UserModel();
    const folder = new FolderModel();
    const createDto = new CreatePrivateChecklistDto();
    const expectedChecklistObject = {
      ...createDto,
      editor: user,
      folder: folder,
    };

    mockChecklistRepository.create.mockReturnValue(expectedChecklistObject);
    mockChecklistRepository.save.mockResolvedValue(expectedChecklistObject);

    const result = await service.createPrivateChecklist(1, 1, createDto);

    expect(mockUsersService.findUserById).toHaveBeenCalledWith(1);
    expect(mockFoldersService.findFolderById).toHaveBeenCalledWith(1);

    expect(mockChecklistRepository.create).toHaveBeenCalledWith(
      expectedChecklistObject,
    );
    expect(mockChecklistRepository.save).toHaveBeenCalledWith(
      expectedChecklistObject,
    );
    expect(result).toEqual(expectedChecklistObject);
  });

  it('service.findAllPrivateChecklists() : 모든 체크리스트를 찾는다.', async () => {
    const checklists = [
      new PrivateChecklistModel(),
      new PrivateChecklistModel(),
    ];
    mockChecklistRepository.find.mockResolvedValue(checklists);

    const result = await service.findAllPrivateChecklists(1, 1);

    expect(mockChecklistRepository.find).toHaveBeenCalledWith({
      where: { folder: { folderId: 1 } },
    });
    expect(result).toEqual(checklists);
  });

  it('service.findPrivateChecklistById(privateChecklistId) : privateChecklistId에 해당하는 체크리스트를 찾는다.', async () => {
    const checklist = new PrivateChecklistModel();
    mockChecklistRepository.findOne.mockResolvedValue(checklist);

    const result = await service.findPrivateChecklistById(1, 1, 1);

    expect(mockChecklistRepository.findOne).toHaveBeenCalledWith({
      where: { privateChecklistId: 1 },
    });
    expect(result).toEqual(checklist);
  });

  it('service.findPrivateChecklistById(privateChecklistId) : 존재하지 않는 체크리스트일 경우 BadRequestException을 던진다.', async () => {
    mockChecklistRepository.findOne.mockResolvedValue(null);

    await expect(service.findPrivateChecklistById(1, 1, 1)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('service.updatePrivateChecklist(privateChecklistId, updateDto) : 체크리스트를 업데이트한다.', async () => {
    const updateDto = new UpdatePrivateChecklistDto();
    const existingChecklist = new PrivateChecklistModel();
    mockChecklistRepository.findOne.mockResolvedValue(existingChecklist);
    mockChecklistRepository.save.mockResolvedValue({
      ...existingChecklist,
      ...updateDto,
    });

    const result = await service.updatePrivateChecklist(1, 1, 1, updateDto);

    expect(mockChecklistRepository.findOne).toHaveBeenCalledWith({
      where: { privateChecklistId: 1 },
    });
    expect(mockChecklistRepository.save).toHaveBeenCalledWith({
      ...existingChecklist,
      ...updateDto,
    });
    expect(result).toEqual({ ...existingChecklist, ...updateDto });
  });

  it('service.updatePrivateChecklist(privateChecklistId, updateDto) : title만 업데이트한다.', async () => {
    const updateDto = new UpdatePrivateChecklistDto();
    updateDto.title = 'Updated Title';
    const existingChecklist = new PrivateChecklistModel();
    existingChecklist.title = 'Original Title';

    mockChecklistRepository.findOne.mockResolvedValue(existingChecklist);
    mockChecklistRepository.save.mockResolvedValue({
      ...existingChecklist,
      ...updateDto,
    });

    const result = await service.updatePrivateChecklist(1, 1, 1, updateDto);

    expect(mockChecklistRepository.findOne).toHaveBeenCalledWith({
      where: { privateChecklistId: 1 },
    });
    expect(mockChecklistRepository.save).toHaveBeenCalledWith({
      ...existingChecklist,
      title: updateDto.title, // title이 업데이트되었는지 확인
    });
    expect(result.title).toEqual(updateDto.title); // 결과의 title이 업데이트된 title과 일치하는지 확인
  });

  it('service.updatePrivateChecklist(privateChecklistId, updateDto) : 존재하지 않는 체크리스트일 경우 BadRequestException을 던진다.', async () => {
    const updateDto = new UpdatePrivateChecklistDto();
    mockChecklistRepository.findOne.mockResolvedValue(null);

    await expect(
      service.updatePrivateChecklist(1, 1, 1, updateDto),
    ).rejects.toThrow(BadRequestException);
  });

  it('service.removePrivateChecklist(privateChecklistId) : 체크리스트를 삭제한다.', async () => {
    const checklist = new PrivateChecklistModel();
    mockChecklistRepository.findOne.mockResolvedValue(checklist);

    const result = await service.removePrivateChecklist(1, 1, 1);

    expect(mockChecklistRepository.findOne).toHaveBeenCalledWith({
      where: { privateChecklistId: 1 },
    });
    expect(mockChecklistRepository.remove).toHaveBeenCalledWith(checklist);
    expect(result).toEqual({ message: '삭제되었습니다.' });
  });

  it('service.removePrivateChecklist(privateChecklistId) : 존재하지 않는 체크리스트일 경우 BadRequestException을 던진다.', async () => {
    mockChecklistRepository.findOne.mockResolvedValue(null);

    await expect(service.removePrivateChecklist(1, 1, 1)).rejects.toThrow(
      BadRequestException,
    );
  });
});
