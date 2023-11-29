import {
  Entity,
  JoinTable,
  ManyToMany,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { ChecklistModel } from '../../common/entity/checklist.entity';
import { UserModel } from '../../users/entities/user.entity';
import { SharedChecklistItemModel } from './shared-checklist-item.entity';

@Entity()
export class SharedChecklistModel extends ChecklistModel {
  @PrimaryGeneratedColumn()
  sharedChecklistId: number;

  @ManyToMany(() => UserModel, (user) => user.sharedChecklists, {
    nullable: false,
  })
  @JoinTable()
  editors: UserModel[];

  @OneToMany(() => SharedChecklistItemModel, (item) => item.sharedChecklist)
  items: SharedChecklistItemModel[];
}
