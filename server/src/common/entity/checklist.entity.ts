import { BaseModel } from './base.entity';
// import { IsNumber } from 'class-validator';
import { Column } from 'typeorm';

export abstract class ChecklistModel extends BaseModel {
  @Column()
  title: string;

  @Column({ nullable: true })
  mainCategory: string;

  @Column({ nullable: true })
  subCategory: string;

  @Column({ nullable: true })
  minorCategory: string;
}
