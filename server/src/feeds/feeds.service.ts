import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FeedModel } from './entity/feed.entity';
import { Repository } from 'typeorm';

@Injectable()
export class FeedsService {
  constructor(
    @InjectRepository(FeedModel)
    private readonly repository: Repository<FeedModel>,
  ) {}

  async findFeedById(feedId: number) {
    const feed = await this.repository.findOne({ where: { feedId } });
    if (!feed) {
      throw new BadRequestException(
        `${feedId}는 존재하지 않는 피드 id 입니다.`,
      );
    }
    return feed;
  }

  findAllFeedsByCategory(mainCategory: string) {
    return this.repository.find({ where: { mainCategory } });
  }

  async updateLikeCount(feedId: number) {
    const feed = await this.findFeedById(feedId);
    feed.likeCount += 1;
    return this.repository.save(feed);
  }

  async updateDownloadCount(feedId: number) {
    const feed = await this.findFeedById(feedId);
    feed.downloadCount += 1;
    return this.repository.save(feed);
  }
}
