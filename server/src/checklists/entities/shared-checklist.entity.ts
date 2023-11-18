import { Entity, ManyToOne } from 'typeorm';
import { ChecklistModel } from '../../common/entity/checklist.entity';
import { UserModel } from '../../users/entities/user.entity';

@Entity()
export class SharedChecklistModel extends ChecklistModel {
  @ManyToOne(() => UserModel, (user) => user.sharedChecklists, {
    nullable: false,
  })
  author: UserModel;
}
