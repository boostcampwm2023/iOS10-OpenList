import { BaseModel } from 'src/common/entity/base.entity';
import { Column, Entity, Generated, OneToMany } from 'typeorm';
import { PrivateChecklistModel } from '../../checklists/entities/private-checklist.entity';
import { SharedChecklistModel } from '../../checklists/entities/shared-checklist.entity';

@Entity()
export class UserModel extends BaseModel {
  @Column({ unique: true })
  email: string;

  @Column()
  @Generated('uuid') // 임시로 uuid를 생성해줌(원래는 provider의 고유 id를 받아와야함)
  providerId: string;

  @Column({ default: 'APPLE' })
  provider: string;

  @Column()
  nickname: string;

  @Column({ default: 'testimagelink' })
  profileImage: string;

  @OneToMany(() => PrivateChecklistModel, (checklist) => checklist.author)
  privateChecklists: PrivateChecklistModel[];

  @OneToMany(() => SharedChecklistModel, (checklist) => checklist.author)
  sharedChecklists: SharedChecklistModel[];
}
