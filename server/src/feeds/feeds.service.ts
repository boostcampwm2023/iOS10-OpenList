import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FeedModel } from './entities/feed.entity';
import { Repository } from 'typeorm';
import { CategoryModel } from '../categories/entities/category.entity';

@Injectable()
export class FeedsService {
  constructor(
    @InjectRepository(FeedModel)
    private readonly repository: Repository<FeedModel>,
    @InjectRepository(CategoryModel)
    private readonly categoryRepository: Repository<CategoryModel>,
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

  async findAllFeedsByCategory(mainCategory: string) {
    // mainCategory를 사용하여 CategoryModel 찾기
    const category = await this.categoryRepository.findOne({
      where: { mainCategory },
    });
    if (!category) {
      throw new BadRequestException(
        `${mainCategory}는 존재하지 않는 카테고리입니다.`,
      );
    }

    // 해당 카테고리 ID를 가진 모든 피드 검색
    const feeds = await this.repository.find({
      where: { category: category },
    });
    if (feeds.length === 0) {
      throw new BadRequestException(
        `${mainCategory}에 대한 피드가 존재하지 않습니다.`,
      );
    }
    return feeds;
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
