import { PartialType } from '@nestjs/mapped-types';
import { SharedChecklistModel } from '../entities/shared-checklist.entity';
import { IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdateSharedChecklistDto extends PartialType(
  SharedChecklistModel,
) {
  @IsString()
  @IsOptional()
  title?: string;

  @IsNumber({}, { each: true })
  @IsOptional()
  editorsId?: number[] = [];
}
