import { BaseModel } from './base.entity';
import { Column, OneToOne } from 'typeorm';
import { CategoryModel } from '../../categories/entities/category.entity';

export abstract class ChecklistModel extends BaseModel {
  @Column()
  title: string;

  @OneToOne(() => CategoryModel, (item) => item.mainCategory)
  mainCategory: string;

  @OneToOne(() => CategoryModel, (item) => item.subCategory)
  subCategory: string;

  @OneToOne(() => CategoryModel, (item) => item.minorCategory)
  minorCategory: string;
}
