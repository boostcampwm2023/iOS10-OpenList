import { Injectable } from '@nestjs/common';
import { CreateShareChecklistSocketDto } from './dto/create-share-checklist-socket.dto';
import { UpdateShareChecklistSocketDto } from './dto/update-share-checklist-socket.dto';

@Injectable()
export class ShareChecklistSocketService {
  create(createShareChecklistSocketDto: CreateShareChecklistSocketDto) {
    return 'This action adds a new shareChecklistSocket';
  }

  findAll() {
    return `This action returns all shareChecklistSocket`;
  }

  findOne(id: number) {
    return `This action returns a #${id} shareChecklistSocket`;
  }

  update(id: number, updateShareChecklistSocketDto: UpdateShareChecklistSocketDto) {
    return `This action updates a #${id} shareChecklistSocket`;
  }

  remove(id: number) {
    return `This action removes a #${id} shareChecklistSocket`;
  }
}
