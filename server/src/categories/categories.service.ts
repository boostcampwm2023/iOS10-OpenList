import { BadRequestException, Injectable } from '@nestjs/common';
import { CATEGORIES } from './const/categories.const';

@Injectable()
export class CategoriesService {
  /**
   * 모든 대카테고리 반환
   * @returns {{id: number, name: string}[]}
   */
  findMainCategories(): { id: number; name: string }[] {
    return CATEGORIES.mainCategory.map(({ id, name }) => ({ id, name }));
  }

  /**
   * 특정 대카테고리의 중카테고리 반환
   * @param {number} mainId
   * @returns {{id: number, name: string}[]}
   */
  findSubCategories(mainId: number): { id: number; name: string }[] {
    // 특정 대카테고리의 중카테고리만 반환
    const mainCategory = CATEGORIES.mainCategory.find(
      (category) => category.id === (mainId as unknown as number),
    );
    if (!mainCategory) {
      throw new BadRequestException(
        `대 카테고리 ID ${mainId}은/는 존재하지 않습니다.`,
      );
    }
    return mainCategory.subcategories.map(({ id, name }) => ({ id, name }));
  }

  /**
   * 특정 중카테고리의 소카테고리 반환
   * @param {number} mainId
   * @param {number} subId
   * @returns {{id: number; name: string}[]}
   */
  findMinorCategories(
    mainId: number,
    subId: number,
  ): { id: number; name: string }[] {
    const mainCategory = CATEGORIES.mainCategory.find(
      (category) => category.id === (mainId as unknown as number),
    );
    if (!mainCategory) {
      throw new BadRequestException(
        `대 카테고리 ID ${mainId}은/는 존재하지 않습니다.`,
      );
    }
    const subCategory = mainCategory.subcategories.find(
      (sub) => sub.id === (subId as unknown as number),
    );
    if (!subCategory) {
      throw new BadRequestException(
        `중 카테고리 ID ${subId}은/는 존재하지 않습니다.`,
      );
    }
    return subCategory.minorCategories;
  }
}
