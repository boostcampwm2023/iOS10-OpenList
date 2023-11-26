import { CreateDateColumn, UpdateDateColumn } from 'typeorm';

export abstract class BaseModel {
  // @PrimaryGeneratedColumn()
  // id: number;

  @UpdateDateColumn()
  updatedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
