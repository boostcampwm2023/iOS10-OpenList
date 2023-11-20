import { PickType } from '@nestjs/mapped-types';
import { SharedChecklistModel } from '../entities/shared-checklist.entity';
import { IsNumber } from 'class-validator';

export class CreateSharedChecklistDto extends PickType(SharedChecklistModel, [
  'title',
]) {
  @IsNumber({}, { each: true })
  editorsId: number[] = [];
}
