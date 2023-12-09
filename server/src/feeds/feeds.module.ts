import { Module } from '@nestjs/common';
import { FeedsService } from './feeds.service';
import { FeedsController } from './feeds.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FeedModel } from './entities/feed.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FeedModel])],
  controllers: [FeedsController],
  providers: [FeedsService],
})
export class FeedsModule {}
