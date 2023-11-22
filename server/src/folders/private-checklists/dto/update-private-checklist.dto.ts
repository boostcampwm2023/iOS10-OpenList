import { PartialType } from '@nestjs/mapped-types';
import { PrivateChecklistModel } from '../entities/private-checklist.entity';
import { IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdatePrivateChecklistDto extends PartialType(
  PrivateChecklistModel,
) {
  @IsString()
  @IsOptional()
  title?: string;

  @IsNumber()
  @IsOptional()
  folderId?: number;
}
