import { Entity, ManyToMany } from 'typeorm';
import { ChecklistModel } from '../../common/entity/checklist.entity';
import { UserModel } from '../../users/entities/user.entity';
import { JoinTable } from 'typeorm/browser';

@Entity()
export class SharedChecklistModel extends ChecklistModel {
  @ManyToMany(() => UserModel, (user) => user.sharedChecklists, {
    nullable: false,
  })
  @JoinTable()
  editors: UserModel[];
}
