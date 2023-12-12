import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CategoryModel } from './entities/category.entity';
import { Repository } from 'typeorm';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(CategoryModel)
    private readonly categoryModelRepository: Repository<CategoryModel>,
  ) {}

  /**
   * 대카테고리 반환
   * @returns {Promise<{name: string}[]>}
   */
  async findMainCategories(): Promise<{ name: string }[]> {
    const categories = await this.categoryModelRepository
      .createQueryBuilder('category')
      .select('category.mainCategory', 'name')
      .distinct(true)
      .getRawMany();

    if (!categories.length)
      throw new BadRequestException('대카테고리가 존재하지 않습니다.');
    return categories;
  }

  /**
   * 특정 대카테고리의 중카테고리 반환
   * @param {string} mainCategory
   * @returns {Promise<{name: string}[]>}
   */
  async findSubCategories(mainCategory: string): Promise<{ name: string }[]> {
    const categories = await this.categoryModelRepository
      .createQueryBuilder('category')
      .select('category.subCategory', 'name')
      .where('category.mainCategory = :mainCategory', { mainCategory })
      .distinct(true)
      .getRawMany();

    if (!categories.length)
      throw new BadRequestException(
        `${mainCategory}에 대한 중카테고리가 존재하지 않습니다.`,
      );
    return categories;
  }

  /**
   * 특정 중카테고리의 소카테고리 반환
   * @param {string} mainCategory
   * @param {string} subCategory
   * @returns {Promise<{name: string}[]>}
   */
  async findMinorCategories(
    mainCategory: string,
    subCategory: string,
  ): Promise<{ name: string }[]> {
    const categories = await this.categoryModelRepository
      .createQueryBuilder('category')
      .select('category.minorCategory', 'name')
      .where('category.mainCategory = :mainCategory', { mainCategory })
      .andWhere('category.subCategory = :subCategory', { subCategory })
      .distinct(true)
      .getRawMany();

    if (!categories.length)
      throw new BadRequestException(
        `${mainCategory}-${subCategory}에 대한 소카테고리가 존재하지 않습니다.`,
      );
    return categories;
  }
}
