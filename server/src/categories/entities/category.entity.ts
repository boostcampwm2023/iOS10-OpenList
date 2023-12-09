import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
class CategoryModel {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  mainCategory: string;

  @Column()
  subCategory: string;

  @Column()
  minorCategory: string;
}
