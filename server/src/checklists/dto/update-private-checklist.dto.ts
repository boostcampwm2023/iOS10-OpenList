import { PickType } from '@nestjs/mapped-types';
import { PrivateChecklistModel } from '../entities/private-checklist.entity';

export class UpdatePrivateChecklistDto extends PickType(PrivateChecklistModel, [
  'title',
  ,
  'folder',
]) {}
