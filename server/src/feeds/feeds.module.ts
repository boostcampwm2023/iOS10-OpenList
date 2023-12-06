import { Module } from '@nestjs/common';
import { FeedsService } from './feeds.service';
import { FeedsController } from './feeds.controller';

@Module({
  controllers: [FeedsController],
  providers: [FeedsService],
})
export class FeedsModule {}
