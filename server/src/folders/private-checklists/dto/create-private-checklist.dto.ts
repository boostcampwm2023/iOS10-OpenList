import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import { IsArray, IsNotEmpty, IsString, ValidateNested } from 'class-validator';
import {
  ChecklistItem,
  PrivateChecklistModel,
} from '../entities/private-checklist.entity';

export class CreatePrivateChecklistDto extends PartialType(
  PrivateChecklistModel,
) {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ChecklistItem)
  items: ChecklistItem[];
}
