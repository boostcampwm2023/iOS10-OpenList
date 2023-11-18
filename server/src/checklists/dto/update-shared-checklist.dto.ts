import { PickType } from '@nestjs/mapped-types';
import { SharedChecklistModel } from '../entities/shared-checklist.entity';
import { IsOptional } from 'class-validator';

export class UpdateSharedChecklistDto extends PickType(SharedChecklistModel, [
  'title',
  'progress',
]) {
  @IsOptional()
  editors: number[] = [];
}
