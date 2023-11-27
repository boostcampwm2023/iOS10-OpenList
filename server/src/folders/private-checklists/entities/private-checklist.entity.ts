import { IsBoolean, IsString } from 'class-validator';
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { ChecklistModel } from '../../../common/entity/checklist.entity';
import { UserModel } from '../../../users/entities/user.entity';
import { FolderModel } from '../../entities/folder.entity';

export class ChecklistItem {
  @IsBoolean()
  isChecked: boolean;

  @IsString()
  value: string;
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
  items: ChecklistItem[];
}
