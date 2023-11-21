import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderModel } from './entities/folder.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';

@Injectable()
export class FoldersService {
  constructor(
    @InjectRepository(FolderModel)
    private readonly folderRepository: Repository<FolderModel>,
    private readonly usersService: UsersService,
  ) {}
  async createFolder(uId, dto: CreateFolderDto) {
    const owner = await this.usersService.findUserById(uId);
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

  async findAllFolders(uId) {
    const folders = await this.folderRepository.find({
      where: { owner: { id: uId } },
      relations: ['owner'],
    });
    return folders;
  }

  async findFolderById(id: number) {
    const folder = await this.folderRepository.findOne({
      where: { id },
      relations: ['owner'],
    });
    if (!folder) {
      throw new BadRequestException('존재하지 않는 폴더입니다.');
    }
    return folder;
  }

  async updateFolder(id: number, dto: UpdateFolderDto) {
    const folder = await this.findFolderById(id);
    const updatedFolder = await this.folderRepository.save({
      ...folder,
      ...dto,
    });
    return updatedFolder;
  }

  async removeFolder(id: number) {
    const folder = await this.findFolderById(id);
    await this.folderRepository.remove(folder);
    return { message: '삭제되었습니다.' };
  }
}
