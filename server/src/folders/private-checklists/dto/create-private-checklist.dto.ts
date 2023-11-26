import { PartialType } from '@nestjs/mapped-types';
import { IsNotEmpty, IsObject, IsString } from 'class-validator';
import {
  ChecklistContent,
  PrivateChecklistModel,
} from '../entities/private-checklist.entity';

export class CreatePrivateChecklistDto extends PartialType(
  PrivateChecklistModel,
) {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsObject()
  @IsNotEmpty()
  content: ChecklistContent;
}
