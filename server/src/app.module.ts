import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WinstonModule } from 'nest-winston';
import { RedisModule } from 'redis/redis.module';
import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { ChecklistAiModule } from './checklist-ai/checklist-ai.module';
import { CommonModule } from './common/common.module';
import { LoggingInterceptor } from './common/interceptor/log.interceptor';
import { LoggerMiddleware } from './common/middlewares/logger.middleware';
import { FeedModel } from './feeds/entity/feed.entity';
import { FeedsModule } from './feeds/feeds.module';
import { FolderModel } from './folders/entities/folder.entity';
import { FoldersModule } from './folders/folders.module';
import { PrivateChecklistModel } from './folders/private-checklists/entities/private-checklist.entity';
import { ChecklistsModule } from './folders/private-checklists/private-checklists.module';
import { SharedChecklistItemModel } from './shared-checklists/entities/shared-checklist-item.entity';
import { SharedChecklistModel } from './shared-checklists/entities/shared-checklist.entity';
import { SharedChecklistsModule } from './shared-checklists/shared-checklists.module';
import { UserModel } from './users/entities/user.entity';
import { UsersModule } from './users/users.module';
import { winstonConfig } from './utils/winston.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
      isGlobal: true,
    }),
    RedisModule.forRoot(),
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
        SharedChecklistItemModel,
        FeedModel,
      ],
      synchronize: true, // DO NOT USE IN PRODUCTION
    }),
    WinstonModule.forRoot(winstonConfig),
    CommonModule,
    UsersModule,
    FoldersModule,
    ChecklistsModule,
    AuthModule,
    SharedChecklistsModule,
    ChecklistAiModule,
    CategoriesModule,
    FeedsModule,
    AdminModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(LoggerMiddleware)
      .forRoutes({ path: '*', method: RequestMethod.ALL });
  }
}
