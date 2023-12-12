import { HttpService } from '@nestjs/axios';
import {
  Inject,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { CreateChecklistItemsDto } from './dto/create-checklist-items.dto';
import { RedisClientType } from 'redis';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AiChecklistItemModel } from './entities/ai-checklist-item';

@Injectable()
export class ChecklistAiService {
  constructor(
    private httpService: HttpService,
    @InjectRepository(AiChecklistItemModel)
    private readonly aiChecklistItemModelRepository: Repository<AiChecklistItemModel>,
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
  ) {}

  async findAiChecklistItems(dto: CreateChecklistItemsDto): Promise<any[]> {
    const query = this.aiChecklistItemModelRepository
      .createQueryBuilder('item')
      .select('item.aiChecklistItemId', 'id')
      .addSelect('item.content', 'content')
      .innerJoin('item.category', 'category')
      .where('category.mainCategory = :mainCategory', {
        mainCategory: dto.mainCategory,
      })
      .andWhere('category.subCategory = :subCategory', {
        subCategory: dto.subCategory,
      })
      .andWhere('category.minorCategory = :minorCategory', {
        minorCategory: dto.minorCategory,
      })
      .orderBy('item.final_score', 'DESC')
      .limit(50);

    const items = await query.getRawMany();
    // 무작위로 10개 선택
    const randomItems = this.selectRandomItems(items, 10);
    return randomItems;
  }

  private selectRandomItems(items: any[], count: number): any[] {
    const shuffled = items.sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
  }

  async getAiItemCountByCategories() {
    const categoriesCount = await this.aiChecklistItemModelRepository
      .createQueryBuilder('item')
      .select('category.mainCategory', 'mainCategory')
      .addSelect('category.subCategory', 'subCategory')
      .addSelect('category.minorCategory', 'minorCategory')
      .addSelect('COUNT(item.aiChecklistItemId)', 'itemCount')
      .innerJoin('item.category', 'category')
      .groupBy('category.mainCategory')
      .addGroupBy('category.subCategory')
      .addGroupBy('category.minorCategory')
      .getRawMany();

    console.log('categoriesCount', categoriesCount);
    return categoriesCount;
  }

  async getCategoriesLessThanCount(count: number) {
    const categories = await this.aiChecklistItemModelRepository
      .createQueryBuilder('item')
      .select('category.mainCategory', 'main')
      .addSelect('category.subCategory', 'sub')
      .addSelect('category.minorCategory', 'minor')
      .addSelect('category.categoryId', 'categoryId')
      .addSelect('COUNT(item.aiChecklistItemId)', 'itemCount') // 여기서 별칭 지정
      .innerJoin('item.category', 'category')
      .groupBy('category.categoryId')
      .having('COUNT(item.aiChecklistItemId) < :count', { count }) // 집계 함수 사용
      .getRawMany();

    const formattedCategories = categories.map((cat) => [
      cat.main,
      cat.sub,
      cat.minor,
      cat.categoryId,
    ]);

    if (formattedCategories.length === 0) {
      throw new ServiceUnavailableException('조건에 맞는 카테고리가 없습니다.');
    }
    this.redisPublisher.publish(
      'ai_generate',
      JSON.stringify({
        messageData: `${count}개 이하의 아이템을 가진 카테고리 ${formattedCategories.length}목록`,
        categories: formattedCategories,
      }),
    );

    return formattedCategories;
  }

  formatCategoryData(categoriesCount) {
    return categoriesCount.map((category) => {
      return `[${category.mainCategory}, ${category.subCategory}, ${category.minorCategory}] - ${category.itemCount}개`;
    });
  }

  publishToRedis(channel, messageData, formattedData) {
    console.log('formattedData', formattedData);
    this.redisPublisher.publish(
      channel,
      JSON.stringify({
        messageData: messageData,
        categories: formattedData,
      }),
    );
  }

  async publishToCountItemsByCategory() {
    const categoriesCount = await this.getAiItemCountByCategories();
    const formattedData = this.formatCategoryData(categoriesCount);
    this.publishToRedis('itemCount', 'itemCount', formattedData);
    return formattedData;
  }

  async publishToGenerateItemsLessThanCount(count: number) {
    const categories = await this.getCategoriesLessThanCount(count);
    this.publishToRedis('ai_generate', 'generateGptData', categories);
    return categories;
  }
}
