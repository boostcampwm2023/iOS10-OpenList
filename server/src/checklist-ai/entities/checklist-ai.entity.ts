import {
  Column,
  Entity,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { AiChecklistItemNaverReasonModel } from '../../reasons/entities/ai-checklist-item-naver-reason.entity';
import { BaseModel } from '../../common/entities/base.entity';
import { CategoryModel } from '../../categories/entities/category.entity';

@Entity()
export class AiChecklistItemModel extends BaseModel {
  @PrimaryGeneratedColumn()
  aiChecklistItemId: number;

  @Column()
  content: string;

  @Column({ default: 0 })
  selected_count_by_user: number;

  @Column({ default: 0 })
  selected_count_by_naver_ai: number;

  @Column({ default: 0 })
  evaluated_count_by_naver_ai: number;

  // final_score는 user_selected_count + naver_ai_selected_count + naver_ai_evaluate_count
  @Column({ default: 0 })
  final_score: number;

  @OneToOne(() => CategoryModel, (item) => item.mainCategory)
  mainCategory: string;

  @OneToOne(() => CategoryModel, (item) => item.subCategory)
  subCategory: string;

  @OneToOne(() => CategoryModel, (item) => item.minorCategory)
  minorCategory: string;

  @OneToMany(
    () => AiChecklistItemNaverReasonModel,
    (reason) => reason.aiChecklistItem,
  )
  reasons: AiChecklistItemNaverReasonModel[];
}
