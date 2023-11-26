import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { ChecklistModel } from '../../../common/entity/checklist.entity';
import { UserModel } from '../../../users/entities/user.entity';
import { FolderModel } from '../../entities/folder.entity';

export interface ChecklistItem {
  isChecked: boolean;
  value: string;
}

export interface ChecklistContent {
  [key: number]: ChecklistItem;
}

@Entity()
export class PrivateChecklistModel extends ChecklistModel {
  @PrimaryGeneratedColumn()
  privateChecklistId: number;

  @ManyToOne(() => UserModel, (user) => user.privateChecklists, {
    nullable: false,
  })
  editor: UserModel;

  @ManyToOne(() => FolderModel, (folder) => folder.privateChecklists, {
    nullable: false,
  })
  folder: FolderModel;

  @Column({ type: 'json' })
  content: ChecklistContent;
}
