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
    @UserId() userId: number,
    @Body() dto: CreatePrivateChecklistDto,
  ) {
    return this.checklistsService.createPrivateChecklist(folderId, userId, dto);
  }

  /**
   * @description folderId를 통해 해당 folder의 모든 checklist를 조회합니다.
   * @param {number} folderId
   * @returns {Promise<PrivateChecklistModel[]>}
   */
  @Get()
  getAllPrivateChecklists(
    @Param('folderId') folderId: number,
    @UserId() userId: number,
  ) {
    return this.checklistsService.findAllPrivateChecklists(folderId, userId);
  }

  /**
   * @description checklistId를 통해 해당 checklist를 조회합니다.
   * @param {number} privateChecklistId
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Get(':privateChecklistId')
  getPrivateChecklist(
    @Param('folderId') folderId: number,
    @Param('privateChecklistId') privateChecklistId: number,
    @UserId() userId: number,
  ) {
    return this.checklistsService.findPrivateChecklistById(
      folderId,
      privateChecklistId,
      userId,
    );
  }

  /**
   * @description checklistId를 통해 해당 checklist의 title을 수정합니다.
   * @param {number} privateChecklistId
   * @param {UpdatePrivateChecklistDto} dto
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Put(':privateChecklistId')
  putPrivateChecklist(
    @Param('folderId') folderId: number,
    @Param('privateChecklistId') privateChecklistId: number,
    @UserId() userId: number,
    @Body() dto: UpdatePrivateChecklistDto,
  ) {
    return this.checklistsService.updatePrivateChecklist(
      folderId,
      privateChecklistId,
      userId,
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
    @Param('folderId') folderId: number,
    @Param('privateChecklistId') privateChecklistId: number,
    @UserId() userId: number,
  ) {
    return this.checklistsService.removePrivateChecklist(
      folderId,
      privateChecklistId,
      userId,
    );
  }
}
