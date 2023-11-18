import { BaseModel } from './base.entity';
import { IsNumber } from 'class-validator';
import { Column } from 'typeorm';

export abstract class ChecklistModel extends BaseModel {
  @Column({ default: '새 체크리스트' })
  title: string;

  @Column({ default: 0 })
  @IsNumber()
  progress: number;
}
