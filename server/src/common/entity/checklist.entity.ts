import { BaseModel } from './base.entity';
// import { IsNumber } from 'class-validator';
import { Column } from 'typeorm';

export abstract class ChecklistModel extends BaseModel {
  @Column()
  title: string;

  // @Column({ default: 0 })
  // @IsNumber()
  // progress: number;
}
