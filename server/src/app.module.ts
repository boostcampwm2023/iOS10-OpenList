import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { CommonModule } from './common/common.module';
import { UsersModule } from './users/users.module';
import { UserModel } from './users/entities/user.entity';
import { FoldersModule } from './folders/folders.module';
import { FolderModel } from './folders/entities/folder.entity';
import { ChecklistsModule } from './private-checklists/private-checklists.module';
import { PrivateChecklistModel } from './private-checklists/entities/private-checklist.entity';
import { SharedChecklistModel } from './shared-checklists/entities/shared-checklist.entity';

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
      synchronize: true, // DO NOT USE IN PRODUCTION
    }),
    CommonModule,
    UsersModule,
    FoldersModule,
    ChecklistsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
