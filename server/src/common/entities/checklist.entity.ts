import { BaseModel } from './base.entity';
import { Column, JoinColumn, ManyToOne } from 'typeorm';
import { CategoryModel } from '../../categories/entities/category.entity';

export abstract class ChecklistModel extends BaseModel {
  @Column()
  title: string;

  @ManyToOne(() => CategoryModel)
  @JoinColumn({ name: 'categoryId' })
  category: CategoryModel;
}
