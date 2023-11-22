import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CommonModule } from './common/common.module';
import { FolderModel } from './folders/entities/folder.entity';
import { FoldersModule } from './folders/folders.module';
import { PrivateChecklistModel } from './folders/private-checklists/entities/private-checklist.entity';
import { ChecklistsModule } from './folders/private-checklists/private-checklists.module';
import { SharedChecklistModel } from './shared-checklists/entities/shared-checklist.entity';
import { UserModel } from './users/entities/user.entity';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';

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
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
