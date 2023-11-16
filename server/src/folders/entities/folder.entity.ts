import { BaseModel } from '../../common/entity/base.entity';
import { Column, Entity } from 'typeorm';

@Entity()
export class FolderModel extends BaseModel {
  @Column({ default: '새 폴더' })
  title: string;
}
