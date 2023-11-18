import { Injectable } from '@nestjs/common';
import { CreatePrivateChecklistDto } from './dto/create-private-checklist.dto';
import { UpdatePrivateChecklistDto } from './dto/update-private-checklist.dto';

@Injectable()
export class ChecklistsService {
  create(createChecklistDto: CreatePrivateChecklistDto) {
    return 'This action adds a new checklist';
  }

  findAll() {
    return `This action returns all checklists`;
  }

  findOne(id: number) {
    return `This action returns a #${id} checklist`;
  }

  update(id: number, updateChecklistDto: UpdatePrivateChecklistDto) {
    return `This action updates a #${id} checklist`;
  }

  remove(id: number) {
    return `This action removes a #${id} checklist`;
  }
}
