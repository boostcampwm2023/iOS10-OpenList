import { Entity, JoinTable, ManyToMany, PrimaryGeneratedColumn } from 'typeorm';
import { ChecklistModel } from '../../common/entity/checklist.entity';
import { UserModel } from '../../users/entities/user.entity';

@Entity()
export class SharedChecklistModel extends ChecklistModel {
  @PrimaryGeneratedColumn()
  sharedChecklistId: number;
  @ManyToMany(() => UserModel, (user) => user.sharedChecklists, {
    nullable: false,
  })
  @JoinTable()
  editors: UserModel[];
}
