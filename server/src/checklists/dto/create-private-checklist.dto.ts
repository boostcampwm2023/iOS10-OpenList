import { PartialType } from '@nestjs/mapped-types';
import { PrivateChecklistModel } from '../entities/private-checklist.entity';
import { IsString } from 'class-validator';

export class CreatePrivateChecklistDto extends PartialType(
  PrivateChecklistModel,
) {
  @IsString()
  title: string;
}
