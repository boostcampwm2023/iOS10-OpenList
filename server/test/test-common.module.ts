import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { UserModel } from 'src/users/entities/user.entity';
import { FolderModel } from '../src/folders/entities/folder.entity';
import { PrivateChecklistModel } from '../src/checklists/entities/private-checklist.entity';
import { SharedChecklistModel } from '../src/checklists/entities/shared-checklist.entity';
import { UsersModule } from '../src/users/users.module';
import { FoldersModule } from '../src/folders/folders.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env['DB_HOST'],
      port: parseInt(process.env['DB_PORT']),
      username: process.env['DB_USERNAME'],
      password: process.env['DB_PASSWORD'],
      database: process.env['DB_DATABASE'],
      entities: [
        UserModel,
        FolderModel,
        PrivateChecklistModel,
        SharedChecklistModel,
      ],
      synchronize: true,
    }),
    UsersModule,
    FoldersModule,
  ],
})
export class TestCommonModule {}
