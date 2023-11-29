import { BaseModel } from 'src/common/entity/base.entity';
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { SharedChecklistModel } from './shared-checklist.entity';

@Entity()
export class ShaerdChecklistItemModel extends BaseModel {
  @PrimaryGeneratedColumn()
  itemId: number;

  @ManyToOne(
    () => SharedChecklistModel,
    (sharedChecklist) => sharedChecklist.items,
  )
  sharedChecklist: SharedChecklistModel;

  @Column({ type: 'json' })
  messages: any[];
}
