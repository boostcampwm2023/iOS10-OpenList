import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { PrivateChecklistModel } from '../../folders/private-checklists/entities/private-checklist.entity';

@Entity()
export class FeedModel extends PrivateChecklistModel {
  @PrimaryGeneratedColumn()
  feedId: number;

  @Column({ default: 0 })
  likeCount: number;

  @Column({ default: 0 })
  downloadCount: number;
}
