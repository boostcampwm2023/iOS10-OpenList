import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderModel } from './entities/folder.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class FoldersService {
  constructor(
    @InjectRepository(FolderModel)
    private folderRepository: Repository<FolderModel>,
  ) {}
  async createFolder(createFolderDto: CreateFolderDto) {
    const folderObject = this.folderRepository.create(createFolderDto);
    const folderExists = await this.folderRepository.exist({
      where: {
        title: createFolderDto.title,
      },
    });
    if (folderExists) {
      throw new BadRequestException('이미 존재하는 폴더입니다.');
    }
    const newFolder = await this.folderRepository.save(folderObject);
    return newFolder;
  }

  async findAllFolders() {
    const folders = await this.folderRepository.find();
    return folders;
  }

  async findFolderById(id: number) {
    const folder = await this.folderRepository.findOne({ where: { id } });
    if (!folder) {
      throw new BadRequestException('존재하지 않는 폴더입니다.');
    }
    return folder;
  }

  async updateFolder(id: number, updateFolderDto: UpdateFolderDto) {
    const folder = await this.findFolderById(id);
    const updatedFolder = await this.folderRepository.save({
      ...folder,
      ...updateFolderDto,
    });
    return updatedFolder;
  }

  async removeFolder(id: number) {
    const folder = await this.findFolderById(id);
    await this.folderRepository.remove(folder);
    return { message: '삭제되었습니다.' };
  }
}
