import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { CreateSharedChecklistDto } from './dto/create-shared-checklist.dto';
import { UpdateSharedChecklistDto } from './dto/update-shared-checklist.dto';
import { SharedChecklistModel } from './entities/shared-checklist.entity';

@Injectable()
export class SharedChecklistsService {
  constructor(
    @InjectRepository(SharedChecklistModel)
    private readonly repository: Repository<SharedChecklistModel>,
    private readonly usersService: UsersService,
  ) {}

  async createSharedChecklist(uId: number, dto: CreateSharedChecklistDto) {
    // 1. title을 통해 해당 checklist가 존재하는지 확인합니다.
    const checklistExists = await this.repository.findOne({
      where: {
        title: dto.title,
      },
    });
    if (checklistExists) {
      throw new BadRequestException('이미 존재하는 체크리스트입니다.');
    }

    // 2. editorsId를 통해 해당 유저들이 존재하는지 확인하고 가져옵니다.
    const editors = await Promise.all(
      dto.editorsId.map((id) => this.usersService.findUserById(id)),
    );

    // 3. 새로운 checklist를 생성합니다.
    const newChecklist = this.repository.create({
      title: dto.title,
      editors,
    });

    // 4. 생성된 checklist를 저장하고, 해당 checklist를 반환합니다.
    return this.repository.save(newChecklist);
  }

  async findAllSharedChecklists() {
    const checklists = await this.repository.find();
    return checklists;
  }

  async findSharedChecklistById(sharedChecklistId: number) {
    const checklist = await this.repository.findOne({
      where: { sharedChecklistId },
    });
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }
    return checklist;
  }

  async updateSharedChecklist(id: number, dto: UpdateSharedChecklistDto) {
    const { title, editorsId } = dto;
    const checklist = await this.findSharedChecklistById(id);
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }

    if (title) {
      checklist.title = title;
    }

    if (editorsId) {
      const editors = await Promise.all(
        editorsId.map((id) => this.usersService.findUserById(id)),
      );
      checklist.editors = editors;
    }

    const newChecklist = await this.repository.save(checklist);
    return newChecklist;
  }

  async removeSharedChecklist(id: number) {
    const checklist = await this.findSharedChecklistById(id);

    // soft-delete 방식으로 수정필요
    await this.repository.remove(checklist);
    return { message: '삭제되었습니다.' };
  }
}
