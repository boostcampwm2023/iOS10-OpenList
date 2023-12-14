import { BaseModel } from 'src/common/entities/base.entity';
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { SharedChecklistModel } from './shared-checklist.entity';

@Entity()
export class SharedChecklistItemModel extends BaseModel {
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
