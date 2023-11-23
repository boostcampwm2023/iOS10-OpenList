import { PartialType } from '@nestjs/mapped-types';
import { CreateShareChecklistSocketDto } from './create-share-checklist-socket.dto';

export class UpdateShareChecklistSocketDto extends PartialType(CreateShareChecklistSocketDto) {
  id: number;
}
