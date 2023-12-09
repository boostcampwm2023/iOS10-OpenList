import {
  Column,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { BaseModel } from '../../common/entities/base.entity';
import { UserModel } from '../../users/entities/user.entity';
import { PrivateChecklistModel } from '../private-checklists/entities/private-checklist.entity';

@Entity()
export class FolderModel extends BaseModel {
  @PrimaryGeneratedColumn()
  folderId: number;

  @Column()
  title: string;

  @ManyToOne(() => UserModel, (user) => user.folders, {
    nullable: false,
  })
  owner: UserModel;

  @OneToMany(
    () => PrivateChecklistModel,
    (privateChecklist) => privateChecklist.folder,
  )
  privateChecklists: PrivateChecklistModel[];
}
