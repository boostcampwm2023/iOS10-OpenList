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

  /**
   * 사용자 ID와 폴더 생성 DTO를 받아 새로운 폴더를 생성한다.
   * @param userId 사용자 식별자
   * @param dto 폴더 생성에 필요한 데이터 전송 객체
   * @returns 생성된 폴더 객체
   */
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
    delete newFolder.owner; // owner 필드를 삭제

    return newFolder;
  }

  /**
   * 주어진 사용자 ID에 해당하는 모든 폴더를 찾아 반환한다.
   * @param userId 사용자 식별자
   * @returns 해당 사용자의 폴더 배열
   */
  async findAllFolders(userId: number) {
    const folders = await this.folderRepository.find({
      where: { owner: { userId: userId } },
    });
    return folders;
  }

  /**
   * 폴더 ID와 사용자 ID를 기반으로 특정 폴더를 찾아 반환한다.
   * @param folderId 폴더 식별자
   * @param userId 사용자 식별자
   * @returns 찾아진 폴더 객체
   */
  async findFolderById(folderId: number, userId: number) {
    const folder = await this.folderRepository.findOne({
      where: { folderId, owner: { userId } },
    });
    if (!folder) {
      throw new BadRequestException('존재하지 않는 폴더입니다.');
    }
    return folder;
  }

  /**
   * 폴더 ID, 사용자 ID, 업데이트할 폴더 데이터를 받아 해당 폴더의 정보를 업데이트한다.
   * @param folderId 업데이트할 폴더의 식별자
   * @param userId 사용자 식별자
   * @param dto 폴더 업데이트에 필요한 데이터 전송 객체
   * @returns 업데이트된 폴더 객체
   */
  async updateFolder(folderId: number, userId: number, dto: UpdateFolderDto) {
    const folder = await this.findFolderById(folderId, userId);
    const updatedFolder = await this.folderRepository.save({
      ...folder,
      ...dto,
    });
    return updatedFolder;
  }

  /**
   * 폴더 ID와 사용자 ID를 사용하여 특정 폴더를 삭제한다.
   * @param folderId 삭제할 폴더의 식별자
   * @param userId 사용자 식별자
   * @returns 삭제 성공 메시지
   */
  async removeFolder(folderId: number, userId: number) {
    const folder = await this.findFolderById(folderId, userId);
    await this.folderRepository.remove(folder);
    return { message: '삭제되었습니다.' };
  }
}
