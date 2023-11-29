import { BaseModel } from 'src/common/entity/base.entity';
import {
  Column,
  Entity,
  ManyToMany,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { FolderModel } from '../../folders/entities/folder.entity';
import { PrivateChecklistModel } from '../../folders/private-checklists/entities/private-checklist.entity';
import { SharedChecklistModel } from '../../shared-checklists/entities/shared-checklist.entity';

export enum ProviderType {
  APPLE = 'APPLE',
  GOOGLE = 'GOOGLE',
}
@Entity()
export class UserModel extends BaseModel {
  @PrimaryGeneratedColumn()
  userId: number;

  @Column({ unique: true })
  email: string;

  @Column()
  // @Generated('uuid') // 임시로 uuid를 생성해줌(원래는 provider의 고유 id를 받아와야함)
  providerId: string;

  @Column({
    type: 'enum',
    enum: ProviderType,
  })
  provider: ProviderType;

  @Column()
  fullName: string;

  @Column()
  nickname: string;

  @Column({ default: 'testimagelink' })
  profileImage: string;

  @OneToMany(() => FolderModel, (folder) => folder.owner)
  folders: FolderModel[];

  @OneToMany(() => PrivateChecklistModel, (checklist) => checklist.editor)
  privateChecklists: PrivateChecklistModel[];

  @ManyToMany(() => SharedChecklistModel, (checklist) => checklist.editors)
  sharedChecklists: SharedChecklistModel[];
}
