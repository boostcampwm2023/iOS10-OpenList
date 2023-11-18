import { PickType } from '@nestjs/mapped-types';
import { PrivateChecklistModel } from '../entities/private-checklist.entity';

export class CreatePrivateChecklistDto extends PickType(PrivateChecklistModel, [
  'title',
  'progress',
  'folder',
]) {}
