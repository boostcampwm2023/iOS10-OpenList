import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { UserId } from 'src/users/decorator/userId.decorator';
import { CreateSharedChecklistDto } from './dto/create-shared-checklist.dto';
import { UpdateSharedChecklistDto } from './dto/update-shared-checklist.dto';
import { SharedChecklistsService } from './shared-checklists.service';

@Controller('folders/:folderId/checklists')
export class SharedChecklistsController {
  constructor(private readonly checklistsService: SharedChecklistsService) {}

  /**
   * @description userId와 title을 통해 해당 folder에 새로운 checklist를 생성합니다.
   * @param {CreateSharedChecklistDto} createSharedChecklistDto
   * @returns {Promise<SharedChecklistModel>}
   */
  @Post()
  postSharedChecklist(
    @UserId() userId: number,
    @Body() createSharedChecklistDto: CreateSharedChecklistDto,
  ) {
    return this.checklistsService.createSharedChecklist(
      userId,
      createSharedChecklistDto,
    );
  }

  /**
   * @description 모든 checklist를 조회합니다.
   * @returns {Promise<SharedChecklistModel[]>}
   */
  @Get()
  getAllSharedChecklists() {
    return this.checklistsService.findAllSharedChecklists();
  }

  /**
   * @description checklistId를 통해 해당 checklist를 조회합니다.
   * @param {number} cid
   * @returns {Promise<SharedChecklistModel>}
   */
  @Get(':checklistId')
  getSharedChecklist(@Param('checklistId') cid: number) {
    return this.checklistsService.findSharedChecklistById(cid);
  }

  /**
   * @description checklistId를 통해 해당 checklist의 title을 수정합니다.
   * @param {number} cid
   * @param {UpdateSharedChecklistDto} updateChecklistDto
   * @returns {Promise<SharedChecklistModel>}
   */
  @Put(':checklistId')
  updateSharedChecklist(
    @Param('checklistId') cid: number,
    @Body() updateChecklistDto: UpdateSharedChecklistDto,
  ) {
    return this.checklistsService.updateSharedChecklist(
      cid,
      updateChecklistDto,
    );
  }

  /**
   * @description checklistId를 통해 해당 checklist를 삭제합니다.
   * @param {number} cid
   * @returns {Promise<message:string>}
   */
  @Delete(':checklistId')
  deleteChecklist(@Param('checklistId') cid: number) {
    return this.checklistsService.removeSharedChecklist(cid);
  }
}
