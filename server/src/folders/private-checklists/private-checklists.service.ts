import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../../users/users.service';
import { FoldersService } from '../folders.service';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';
import { PrivateChecklistModel } from './entities/private-checklist.entity';

@Injectable()
export class PrivateChecklistsService {
  constructor(
    @InjectRepository(PrivateChecklistModel)
    private readonly repository: Repository<PrivateChecklistModel>,
    private readonly foldersService: FoldersService,
    private readonly usersService: UsersService,
  ) {}

  async createPrivateChecklist(
    userId: number,
    folderId: number,
    dto: CreatePrivateChecklistDto,
  ) {
    // 1. folderId를 통해 해당 folder가 존재하는지 확인합니다.
    // userId를 통해 user entity를 가져옵니다.
    const folder = await this.foldersService.findFolderById(folderId);
    const user = await this.usersService.findUserById(userId);

    // 3. 새로운 checklist를 생성합니다.
    const newChecklist = this.repository.create({
      ...dto,
      editor: user,
      folder: folder,
    });

    // 4. 생성된 checklist를 저장하고, 해당 checklist를 반환합니다.
    return this.repository.save(newChecklist);
  }

  async findAllPrivateChecklists(folderId: number) {
    const checklists = await this.repository.find({
      where: { folder: { folderId } },
    });
    return checklists;
  }

  async findPrivateChecklistById(privateChecklistId: number) {
    const checklist = await this.repository.findOne({
      where: { privateChecklistId },
    });
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }
    return checklist;
  }

  async updatePrivateChecklist(
    privateChecklistId: number,
    dto: UpdatePrivateChecklistDto,
  ) {
    const { title, folderId } = dto;
    const checklist = await this.findPrivateChecklistById(privateChecklistId);
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }

    if (title) {
      checklist.title = title;
    }

    if (folderId) {
      const folder = await this.foldersService.findFolderById(folderId);
      checklist.folder = folder;
    }

    const newChecklist = await this.repository.save(checklist);
    return newChecklist;
  }

  async removePrivateChecklist(privateChecklistId: number) {
    const checklist = await this.findPrivateChecklistById(privateChecklistId);

    // soft-delete 방식으로 수정필요
    await this.repository.remove(checklist);
    return { message: '삭제되었습니다.' };
  }
}
