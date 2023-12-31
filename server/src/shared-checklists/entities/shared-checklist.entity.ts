import {
  Entity,
  JoinTable,
  ManyToMany,
  OneToMany,
  PrimaryColumn,
} from 'typeorm';
import { ChecklistModel } from '../../common/entities/checklist.entity';
import { UserModel } from '../../users/entities/user.entity';
import { SharedChecklistItemModel } from './shared-checklist-item.entity';

@Entity()
export class SharedChecklistModel extends ChecklistModel {
  @PrimaryColumn({ type: 'uuid' })
  sharedChecklistId: string;

  @ManyToMany(() => UserModel, (user) => user.sharedChecklists, {
    nullable: false,
  })
  @JoinTable()
  editors: UserModel[];

  @OneToMany(() => SharedChecklistItemModel, (item) => item.sharedChecklist)
  items: SharedChecklistItemModel[];
}
