import { BaseModel } from '../../common/entity/base.entity';
import { Column, Entity, ManyToOne, OneToMany } from 'typeorm';
import { PrivateChecklistModel } from '../../private-checklists/entities/private-checklist.entity';
import { UserModel } from '../../users/entities/user.entity';

@Entity()
export class FolderModel extends BaseModel {
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
