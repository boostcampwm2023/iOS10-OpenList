import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectEntityManager, InjectRepository } from '@nestjs/typeorm';
import { UsersService } from 'src/users/users.service';
import { EntityManager, In, MoreThan, Repository } from 'typeorm';
import { CreateSharedChecklistDto } from './dto/create-shared-checklist.dto';
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

    private readonly usersService: UsersService,
  ) {}
  /**
   * 사용자 ID와 공유 체크리스트 데이터를 받아 새로운 공유 체크리스트를 생성한다.
   * @param userId 사용자 식별자
   * @param dto 공유 체크리스트 생성에 필요한 데이터 전송 객체
   * @returns 생성된 공유 체크리스트 객체
   */
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

  /**
   * 체크리스트 아이템 데이터와 체크리스트 ID를 받아 새로운 체크리스트 아이템을 생성한다.
   * @param items 체크리스트 아이템의 메시지 배열
   * @param checklistId 체크리스트 식별자
   * @param now  전달되는 현재 시간(옵션)
   * @returns 생성된 체크리스트 아이템 객체
   */
  async createSharedChecklistItem(
    items: string[],
    checklistId: string,
    now?: Date,
  ) {
    // 새 ChecklistItem 생성
    const checklistItemData = {
      messages: items,
      sharedChecklist: { sharedChecklistId: checklistId },
    };

    if (now) {
      checklistItemData['createdAt'] = now;
      checklistItemData['updatedAt'] = now;
    }

    const newChecklistItem =
      this.SharedChecklistItemsrepository.create(checklistItemData);

    return this.SharedChecklistItemsrepository.save(newChecklistItem);
  }

  /**
   * 사용자 ID와 공유 체크리스트 데이터를 받아 새로운 공유 체크리스트와 체크리스트 아이템을 함께 생성한다.
   * @param userId 사용자 식별자
   * @param dto 공유 체크리스트 생성에 필요한 데이터 전송 객체
   * @returns 생성된 공유 체크리스트와 체크리스트 아이템 객체
   */
  async createSharedChecklistAndItems(
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

  /**
   * 사용자 ID를 기반으로 모든 공유 체크리스트를 조회한다.
   * @param userId 사용자 식별자
   * @returns 해당 사용자의 모든 공유 체크리스트 배열
   */
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

  /**
   * 공유 체크리스트 ID와 사용자 ID를 받아 해당 체크리스트와 체크리스트 아이템을 조회한다.
   * @param sharedChecklistId 공유 체크리스트 식별자
   * @param userId 사용자 식별자
   * @param date 특정 날짜 이후의 체크리스트 아이템을 필터링하는 날짜 문자열 (선택적)
   * @returns 조회된 공유 체크리스트와 체크리스트 아이템 객체
   */
  async findSharedChecklistAndItemsById(
    sharedChecklistId: string,
    userId: number,
    date: string,
  ) {
    const sharedChecklist =
      await this.findSharedChecklistById(sharedChecklistId);

    const isEditor = sharedChecklist.editors.some(
      (editor) => editor.userId === userId,
    );
    if (!isEditor) {
      throw new BadRequestException('권한이 없습니다.');
    }

    delete sharedChecklist.editors;

    const items = await this.findSharedChecklistItemsById(
      sharedChecklistId,
      userId,
      date,
    );
    return { sharedChecklist, items };
  }

  /**
   * 공유 체크리스트 ID를 기반으로 공유 체크리스트를 조회한다.
   * @param sharedChecklistId 공유 체크리스트 식별자
   * @returns 조회된 공유 체크리스트 객체
   */
  async findSharedChecklistById(sharedChecklistId: string) {
    const sharedChecklist = await this.SharedChecklistsrepository.findOne({
      where: { sharedChecklistId },
      relations: ['editors'],
    });
    if (!sharedChecklist) {
      throw new BadRequestException('존재하지 않는 체크리스트입니다.');
    }

    return sharedChecklist;
  }

  /**
   * 공유 체크리스트 ID를 기반으로 해당 체크리스트의 모든 아이템을 조회한다.
   * @param sharedChecklistId 공유 체크리스트 식별자
   * @param date 선택적 날짜 필터링 (이 날짜 이후의 아이템만 조회)
   * @returns 조회된 체크리스트 아이템 배열
   */
  async findSharedChecklistItemsById(
    sharedChecklistId: string,
    userId: number,
    date?: string,
  ) {
    // 체크리스트가 존재하는지, 권한이 있는지 확인
    const sharedChecklist =
      await this.findSharedChecklistById(sharedChecklistId);
    if (!sharedChecklist.editors.some((editor) => editor.userId === userId)) {
      throw new BadRequestException('권한이 없습니다.');
    }

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

  /**
   * 사용자 ID를 기반으로 해당 사용자가 편집자로 있는 모든 공유 체크리스트 ID를 조회한다.
   * @param userId 사용자 식별자
   * @returns 해당 사용자가 편집자로 있는 공유 체크리스트 ID 배열
   */
  async findAllSharedChecklistIdsByUserId(userId: number) {
    const checklistIdObjects = await this.entityManager.query(
      `SELECT "sharedChecklistModelSharedChecklistId" FROM shared_checklist_model_editors_user_model WHERE "userModelUserId" = $1`,
      [userId],
    );
    return checklistIdObjects.map(
      (obj) => obj.sharedChecklistModelSharedChecklistId,
    );
  }

  /**
   * 공유 체크리스트 ID와 사용자 ID를 기반으로 새로운 에디터를 해당 체크리스트에 추가한다.
   * @param cid 공유 체크리스트 식별자
   * @param userId 추가할 사용자 식별자
   * @returns 추가 작업에 대한 메시지
   */
  async addEditor(cid: string, userId: number) {
    const checklist = await this.findSharedChecklistById(cid);
    const editorExists = checklist.editors.some(
      (editor) => editor.userId === userId,
    );
    if (editorExists) {
      throw new BadRequestException('이미 공유된 체크리스트입니다.');
    }

    const user = await this.usersService.findUserById(userId);
    checklist.editors.push(user);
    await this.SharedChecklistsrepository.save(checklist);
    return { message: '추가되었습니다.' };
  }

  /**
   * 공유 체크리스트 ID와 사용자 ID를 기반으로 해당 체크리스트에서 사용자를 제거한다.
   * @param id 공유 체크리스트 식별자
   * @param userId 제거할 사용자 식별자
   * @returns 제거 작업에 대한 메시지
   */
  async removeEditor(id: string, userId: number) {
    const checklist = await this.findSharedChecklistById(id);
    checklist.editors = checklist.editors.filter(
      (editor) => editor.userId !== userId,
    );
    await this.SharedChecklistsrepository.save(checklist);
    return { message: '삭제되었습니다.' };
  }
}
