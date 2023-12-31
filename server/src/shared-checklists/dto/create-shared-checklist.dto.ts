import { PickType } from '@nestjs/mapped-types';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';
import { SharedChecklistModel } from '../entities/shared-checklist.entity';

export class CreateSharedChecklistDto extends PickType(SharedChecklistModel, [
  'title',
  'sharedChecklistId',
  'items',
]) {
  // @IsNumber({}, { each: true })
  // editorsId: number[] = [];
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsUUID()
  sharedChecklistId: string;

  @IsNotEmpty()
  items: any;
}
