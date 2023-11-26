import { PartialType } from '@nestjs/mapped-types';
import {
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
} from 'class-validator';
import {
  ChecklistContent,
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

  @IsObject()
  @IsOptional()
  content?: ChecklistContent;
}
