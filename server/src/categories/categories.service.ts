import { Injectable } from '@nestjs/common';
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
   * @returns {Promise<{id: number, name: string}[]>}
   */
  async findMainCategories(): Promise<{ id: number; name: string }[]> {
    const categories = await this.categoryModelRepository.find();
    return categories.map((category) => ({
      id: category.categoryId,
      name: category.mainCategory,
    }));
  }

  /**
   * 특정 대카테고리의 중카테고리 반환
   * @param {number} mainId
   * @returns {{id: number, name: string}[]}
   */
  async findSubCategories(
    mainId: number,
  ): Promise<{ id: number; name: string }[]> {
    const categories = await this.categoryModelRepository.find({
      where: { mainCategory: mainId.toString() },
    });
    return categories.map((category) => ({
      id: category.categoryId,
      name: category.subCategory,
    }));
  }

  /**
   * 특정 중카테고리의 소카테고리 반환
   * @param {number} mainId
   * @param {number} subId
   * @returns {{id: number; name: string}[]}
   */
  async findMinorCategories(
    mainId: number,
    subId: number,
  ): Promise<{ id: number; name: string }[]> {
    const categories = await this.categoryModelRepository.find({
      where: { mainCategory: mainId.toString(), subCategory: subId.toString() },
    });
    return categories.map((category) => ({
      id: category.categoryId,
      name: category.minorCategory,
    }));
  }
}
