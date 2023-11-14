import {Column, Entity, PrimaryGeneratedColumn} from "typeorm";

@Entity()
export class TestModel{
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    test: string;
}