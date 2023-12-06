import { BaseModel } from './base.entity';
// import { IsNumber } from 'class-validator';
import { Column } from 'typeorm';

export abstract class ChecklistModel extends BaseModel {
  @Column()
  title: string;

  @Column()
  mainCategory: string;

  @Column()
  subCategory: string;

  @Column()
  minorCategory: string;
}
