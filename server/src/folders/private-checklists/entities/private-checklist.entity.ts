import { Entity, ManyToOne } from 'typeorm';
import { ChecklistModel } from '../../../common/entity/checklist.entity';
import { UserModel } from '../../../users/entities/user.entity';
import { FolderModel } from '../../entities/folder.entity';

@Entity()
export class PrivateChecklistModel extends ChecklistModel {
  @ManyToOne(() => UserModel, (user) => user.privateChecklists, {
    nullable: false,
  })
  editor: UserModel;

  @ManyToOne(() => FolderModel, (folder) => folder.privateChecklists, {
    nullable: false,
  })
  folder: FolderModel;
}
