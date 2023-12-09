import { Module } from '@nestjs/common';
import { FeedsService } from './feeds.service';
import { FeedsController } from './feeds.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FeedModel } from './entities/feed.entity';
import { CategoriesModule } from '../categories/categories.module';

@Module({
  imports: [TypeOrmModule.forFeature([FeedModel]), CategoriesModule],
  controllers: [FeedsController],
  providers: [FeedsService],
})
export class FeedsModule {}
