import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectEntityManager, InjectRepository } from '@nestjs/typeorm';
import { EntityManager, In, MoreThan, Repository } from 'typeorm';
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

    @InjectEntityManager()
    private entityManager: EntityManager,
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
    const sharedChecklist = await this.createSharedChecklist(userId, dto);
    const items = await this.createSharedChecklistItem(
      dto.items,
      sharedChecklist.sharedChecklistId,
    );
    return { sharedChecklist, items };
  }

  async findAllSharedChecklists(userId: number) {
    const checklistIdsArray =
      await this.findAllSharedChecklistIdsByUserId(userId);
    const checklists = await this.SharedChecklistsrepository.find({
      where: {
        sharedChecklistId: In(checklistIdsArray),
      },
      relations: ['editors'],
    });

    return checklists;
  }

  async findSharedChecklistById(
    sharedChecklistId: string,
    userId: number,
    date: string,
  ) {
    const sharedChecklist = await this.SharedChecklistsrepository.findOne({
      where: { sharedChecklistId },
      relations: ['editors'],
    });
    if (!sharedChecklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }
    if (!sharedChecklist.editors.some((editor) => editor.userId === userId)) {
      throw new BadRequestException('권한이 없습니다.');
    }
    delete sharedChecklist.editors;

    const items = await this.findSharedChecklistItemsById(
      sharedChecklistId,
      date,
    );
    return { sharedChecklist, items };
  }
  async findSharedChecklistItemsById(sharedChecklistId: string, date?: string) {
    const queryOptions = {
      where: { sharedChecklist: { sharedChecklistId } },
    };
    if (date) {
      const dateObj = new Date(date);
      if (!isNaN(dateObj.getTime())) {
        queryOptions.where['createdAt'] = MoreThan(dateObj);
      }
    }

    const checklistItems =
      await this.SharedChecklistItemsrepository.find(queryOptions);

    if (!checklistItems) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }

    return checklistItems;
  }

  async findAllSharedChecklistIdsByUserId(userId: number) {
    const checklistIdObjects = await this.entityManager.query(
      `SELECT "sharedChecklistModelSharedChecklistId" FROM shared_checklist_model_editors_user_model WHERE "userModelUserId" = $1`,
      [userId],
    );
    return checklistIdObjects.map(
      (obj) => obj.sharedChecklistModelSharedChecklistId,
    );
  }

  async updateSharedChecklist(id: string, dto: UpdateSharedChecklistDto) {
    const { title, editorsId } = dto;
    const checklist = await this.findSharedChecklistById(id, 1, '');
    if (!checklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }

    // if (title) {
    //   checklist.title = title;
    // }

    // if (editorsId) {
    //   const editors = await Promise.all(
    //     editorsId.map((id) => this.usersService.findUserById(id)),
    //   );
    //   checklist.editors = editors;
    // }

    // const newChecklist = await this.SharedChecklistsrepository.save(checklist);
    return checklist;
  }

  async removeSharedChecklist(id: string) {
    const checklist = await this.findSharedChecklistById(id, 1, '');

    // soft-delete 방식으로 수정필요
    // await this.SharedChecklistsrepository.remove(checklist);
    return { message: '삭제되었습니다.' };
  }
}
