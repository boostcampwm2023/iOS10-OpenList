import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import {
  ChecklistItem,
  PrivateChecklistModel,
} from '../entities/private-checklist.entity';

export class UpdatePrivateChecklistDto extends PartialType(
  PrivateChecklistModel,
) {
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  title?: string;

  @IsNumber()
  @IsOptional()
  folderId?: number;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ChecklistItem)
  @IsOptional()
  items?: ChecklistItem[];
}
