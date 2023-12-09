import { Column, Entity, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { AiChecklistItemModel } from '../../checklist-ai/entities/checklist-ai.entity';

@Entity()
export class CategoryModel {
  @PrimaryGeneratedColumn()
  categoryId: number;

  @Column()
  mainCategory: string;

  @Column()
  subCategory: string;

  @Column()
  minorCategory: string;

  @OneToOne(() => AiChecklistItemModel, (item) => item.mainCategory)
  mainCategoryItem: AiChecklistItemModel;

  @OneToOne(() => AiChecklistItemModel, (item) => item.subCategory)
  subCategoryItem: AiChecklistItemModel;

  @OneToOne(() => AiChecklistItemModel, (item) => item.minorCategory)
  minorCategoryItem: AiChecklistItemModel;
}
