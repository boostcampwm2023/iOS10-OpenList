import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { BaseModel } from '../../common/entities/base.entity';

@Entity()
export class CategoryModel extends BaseModel {
  @PrimaryGeneratedColumn()
  categoryId: number;

  @Column()
  mainCategory: string;

  @Column()
  subCategory: string;

  @Column()
  minorCategory: string;
}
