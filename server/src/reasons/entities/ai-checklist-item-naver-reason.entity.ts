import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { BaseModel } from '../../common/entities/base.entity';
import { AiChecklistItemModel } from '../../checklist-ai/entities/checklist-ai.entity';

@Entity()
export class AiChecklistItemNaverReasonModel extends BaseModel {
  @PrimaryGeneratedColumn()
  aiChecklistItemNaverReasonid: number;

  @Column()
  reason: string;

  @ManyToOne(
    () => AiChecklistItemModel,
    (aiChecklistItem) => aiChecklistItem.reasons,
    {
      nullable: false,
    },
  )
  aiChecklistItem: AiChecklistItemModel;
}
