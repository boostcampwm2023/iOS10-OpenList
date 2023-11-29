import { PickType } from '@nestjs/mapped-types';
import { SharedChecklistModel } from '../entities/shared-checklist.entity';

export class CreateSharedChecklistDto extends PickType(SharedChecklistModel, [
  'title',
  'sharedChecklistId',
  'items',
]) {
  // @IsNumber({}, { each: true })
  // editorsId: number[] = [];
}
