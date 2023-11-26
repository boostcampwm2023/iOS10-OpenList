import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';
import { PrivateChecklistsService } from './private-checklists.service';

@Controller('folders/:folderId/checklists')
export class PrivateChecklistsController {
  constructor(private readonly checklistsService: PrivateChecklistsService) {}

  /**
   * @description userId와 folderId와 title을 통해 해당 folder에 새로운 checklist를 생성합니다.
   * @param {number} folderId
   * @param {CreatePrivateChecklistDto} dto
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Post()
  postPrivateChecklist(
    @Param('folderId') folderId: number,
    @Body() dto: CreatePrivateChecklistDto,
  ) {
    const userId: number = 2;
    return this.checklistsService.createPrivateChecklist(userId, folderId, dto);
  }

  /**
   * @description folderId를 통해 해당 folder의 모든 checklist를 조회합니다.
   * @param {number} folderId
   * @returns {Promise<PrivateChecklistModel[]>}
   */
  @Get()
  getAllPrivateChecklists(@Param('folderId') folderId: number) {
    return this.checklistsService.findAllPrivateChecklists(folderId);
  }

  /**
   * @description checklistId를 통해 해당 checklist를 조회합니다.
   * @param {number} privateChecklistId
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Get(':privateChecklistId')
  getPrivateChecklist(@Param('privateChecklistId') privateChecklistId: number) {
    return this.checklistsService.findPrivateChecklistById(privateChecklistId);
  }

  /**
   * @description checklistId를 통해 해당 checklist의 title을 수정합니다.
   * @param {number} privateChecklistId
   * @param {UpdatePrivateChecklistDto} dto
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Put(':privateChecklistId')
  putPrivateChecklist(
    @Param('privateChecklistId') privateChecklistId: number,
    @Body() dto: UpdatePrivateChecklistDto,
  ) {
    return this.checklistsService.updatePrivateChecklist(
      privateChecklistId,
      dto,
    );
  }

  /**
   * @description checklistId를 통해 해당 checklist를 삭제합니다.
   * @param {number} privateChecklistId
   * @returns {Promise<message:string>}
   */
  @Delete(':privateChecklistId')
  deletePrivateChecklist(
    @Param('privateChecklistId') privateChecklistId: number,
  ) {
    return this.checklistsService.removePrivateChecklist(privateChecklistId);
  }
}
