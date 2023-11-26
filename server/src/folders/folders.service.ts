import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderModel } from './entities/folder.entity';

@Injectable()
export class FoldersService {
  constructor(
    @InjectRepository(FolderModel)
    private readonly folderRepository: Repository<FolderModel>,
    private readonly usersService: UsersService,
  ) {}
  async createFolder(userId: number, dto: CreateFolderDto) {
    const owner = await this.usersService.findUserById(userId);
    const folderObject = this.folderRepository.create({
      ...dto,
      owner,
    });
    const folderExists = await this.folderRepository.exist({
      where: {
        title: dto.title,
      },
    });
    if (folderExists) {
      throw new BadRequestException('이미 존재하는 폴더입니다.');
    }
    const newFolder = await this.folderRepository.save(folderObject);
    return newFolder;
  }

  async findAllFolders(userId: number) {
    const folders = await this.folderRepository.find({
      where: { owner: { userId: userId } },
      relations: ['owner'],
    });
    return folders;
  }

  async findFolderById(folderId: number) {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
      relations: ['owner'],
    });
    if (!folder) {
      throw new BadRequestException('존재하지 않는 폴더입니다.');
    }
    return folder;
  }

  async updateFolder(folderId: number, dto: UpdateFolderDto) {
    const folder = await this.findFolderById(folderId);
    const updatedFolder = await this.folderRepository.save({
      ...folder,
      ...dto,
    });
    return updatedFolder;
  }

  async removeFolder(folderId: number) {
    const folder = await this.findFolderById(folderId);
    await this.folderRepository.remove(folder);
    return { message: '삭제되었습니다.' };
  }
}
