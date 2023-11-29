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
    // 새 ChecklistItem 생성
    const newChecklistItem = this.SharedChecklistItemsrepository.create({
      messages: dto.items,
      // sharedChecklist 객체는 생성 후 관계가 설정됩니다.
    });

    // 새 Checklist 생성
    const newChecklist = this.SharedChecklistsrepository.create({
      title: dto.title,
      sharedChecklistId: dto.sharedChecklistId,
      // editors 배열에는 UserModel 엔티티의 인스턴스가 포함되어야 합니다.
      editors: [{ userId }],
      // items 배열은 아직 비워둡니다. 저장 후 관계를 설정해야 합니다.
    });

    // 먼저 ChecklistItem 저장
    await this.SharedChecklistItemsrepository.save(newChecklistItem);

    // ChecklistItem과의 관계 설정
    newChecklist.items = [newChecklistItem];

    // Checklist 저장
    return this.SharedChecklistsrepository.save(newChecklist);
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
