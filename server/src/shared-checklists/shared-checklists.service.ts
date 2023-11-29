import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { CreateSharedChecklistDto } from './dto/create-shared-checklist.dto';
import { UpdateSharedChecklistDto } from './dto/update-shared-checklist.dto';
import { SharedChecklistItemModel } from './entities/shared-checklist-item.entity';
import { SharedChecklistModel } from './entities/shared-checklist.entity';

@Injectable()
export class SharedChecklistsService {
  constructor(
    @InjectRepository(SharedChecklistModel)
    private readonly SharedChecklistsrepository: Repository<SharedChecklistModel>,

    @InjectRepository(SharedChecklistItemModel)
    private readonly SharedChecklistItemsrepository: Repository<SharedChecklistItemModel>,

    private readonly usersService: UsersService,
  ) {}
  async createSharedChecklist(userId: number, dto: CreateSharedChecklistDto) {
    // 중복된 sharedChecklistId가 있는지 확인
    const checklistExists = await this.SharedChecklistsrepository.exist({
      where: {
        sharedChecklistId: dto.sharedChecklistId,
      },
    });
    if (checklistExists) {
      throw new BadRequestException('이미 존재하는 체크리스트 아이디입니다.');
    }
    // 새 Checklist 생성
    const newChecklist = this.SharedChecklistsrepository.create({
      title: dto.title,
      sharedChecklistId: dto.sharedChecklistId,
      editors: [{ userId }],
    });
    // Checklist 저장
    return this.SharedChecklistsrepository.save(newChecklist);
  }

  async createSharedChecklistItem(items: string[], checklistId: string) {
    // 새 ChecklistItem 생성
    const newChecklistItem = this.SharedChecklistItemsrepository.create({
      messages: items,
      sharedChecklist: { sharedChecklistId: checklistId },
    });

    return this.SharedChecklistItemsrepository.save(newChecklistItem);
  }

  async createSharedChecklistWithItems(
    userId: number,
    dto: CreateSharedChecklistDto,
  ) {
    const newSharedChecklist = await this.createSharedChecklist(userId, dto);
    const newSharedChecklistItem = await this.createSharedChecklistItem(
      dto.items,
      newSharedChecklist.sharedChecklistId,
    );
    return { newSharedChecklist, newSharedChecklistItem };
  }

  async findAllSharedChecklists(userId: number) {
    const checklists = await this.SharedChecklistsrepository.createQueryBuilder(
      'checklist',
    )
      .innerJoinAndSelect('checklist.editors', 'editor')
      .where('editor.userId = :userId', { userId })
      .getMany();

    return checklists;
  }

  async findSharedChecklistById(sharedChecklistId: string) {
    const checklist = await this.SharedChecklistsrepository.findOne({
      where: { sharedChecklistId },
    });
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }
    return checklist;
  }

  async updateSharedChecklist(id: string, dto: UpdateSharedChecklistDto) {
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

    const newChecklist = await this.SharedChecklistsrepository.save(checklist);
    return newChecklist;
  }

  async removeSharedChecklist(id: string) {
    const checklist = await this.findSharedChecklistById(id);

    // soft-delete 방식으로 수정필요
    await this.SharedChecklistsrepository.remove(checklist);
    return { message: '삭제되었습니다.' };
  }
}
