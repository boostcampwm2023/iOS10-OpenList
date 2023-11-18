import { BaseModel } from '../../common/entity/base.entity';
import { Column, Entity, OneToMany } from 'typeorm';
import { PrivateChecklistModel } from '../../checklists/entities/private-checklist.entity';

@Entity()
export class FolderModel extends BaseModel {
  @Column({ default: '새 폴더' })
  title: string;

  @OneToMany(
    () => PrivateChecklistModel,
    (privateChecklist) => privateChecklist.folder,
  )
  privateChecklists: PrivateChecklistModel[];
}
