import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Put,
} from '@nestjs/common';
import { PrivateChecklistsService } from './private-checklists.service';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';

@Controller('folders/:folderId/checklists')
export class PrivateChecklistsController {
  constructor(private readonly checklistsService: PrivateChecklistsService) {}

  /**
   * @description userId와 folderId와 title을 통해 해당 folder에 새로운 checklist를 생성합니다.
   * @param {number} fid
   * @param {CreatePrivateChecklistDto} dto
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Post()
  postPrivateChecklist(
    @Param('folderId') fid: number,
    @Body() dto: CreatePrivateChecklistDto,
  ) {
    const uId = 1;
    return this.checklistsService.createPrivateChecklist(uId, fid, dto);
  }

  /**
   * @description folderId를 통해 해당 folder의 모든 checklist를 조회합니다.
   * @param {number} fid
   * @returns {Promise<PrivateChecklistModel[]>}
   */
  @Get()
  getAllPrivateChecklists(@Param('folderId') fid: number) {
    return this.checklistsService.findAllPrivateChecklists(fid);
  }

  /**
   * @description checklistId를 통해 해당 checklist를 조회합니다.
   * @param {number} cid
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Get(':checklistId')
  getPrivateChecklist(@Param('checklistId') cid: number) {
    return this.checklistsService.findPrivateChecklistById(cid);
  }

  /**
   * @description checklistId를 통해 해당 checklist의 title을 수정합니다.
   * @param {number} cid
   * @param {UpdatePrivateChecklistDto} dto
   * @returns {Promise<PrivateChecklistModel>}
   */
  @Put(':checklistId')
  putPrivateChecklist(
    @Param('checklistId') cid: number,
    @Body() dto: UpdatePrivateChecklistDto,
  ) {
    return this.checklistsService.updatePrivateChecklist(cid, dto);
  }

  /**
   * @description checklistId를 통해 해당 checklist를 삭제합니다.
   * @param {number} cid
   * @returns {Promise<message:string>}
   */
  @Delete(':checklistId')
  deletePrivateChecklist(@Param('checklistId') cid: number) {
    return this.checklistsService.removePrivateChecklist(cid);
  }
}
