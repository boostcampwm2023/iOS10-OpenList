import { Test, TestingModule } from '@nestjs/testing';
import { CategoriesService } from './categories.service';
import { CATEGORIES } from './const/categories.const';
import { BadRequestException } from '@nestjs/common';

describe('CategoriesService', () => {
  let service: CategoriesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CategoriesService],
    }).compile();

    service = module.get<CategoriesService>(CategoriesService);
  });

  it('findMainCategories() : 모든 대카테고리를 반환한다', () => {
    const result = service.findMainCategories();
    expect(result).toEqual(
      CATEGORIES.mainCategory.map(({ id, name }) => ({ id, name })),
    );
  });

  describe('findSubCategories(mainId)', () => {
    it('존재하는 대카테고리 ID에 대해 중카테고리를 반환한다', () => {
      const mainId = 1; // 존재한다고 가정한 대카테고리 ID
      const result = service.findSubCategories(mainId);
      const expectedSubCategories = CATEGORIES.mainCategory
        .find((cat) => cat.id === mainId)
        ?.subcategories.map(({ id, name }) => ({ id, name }));
      expect(result).toEqual(expectedSubCategories);
    });

    it('존재하지 않는 대카테고리 ID에 대해 BadRequestException을 던진다', () => {
      const mainId = 999; // 존재하지 않는다고 가정한 대카테고리 ID
      expect(() => service.findSubCategories(mainId)).toThrow(
        BadRequestException,
      );
    });
  });

  describe('findMinorCategories(mainId, subId)', () => {
    it('존재하는 중카테고리 ID에 대해 소카테고리를 반환한다', () => {
      const mainId = 1; // 존재한다고 가정한 대카테고리 ID
      const subId = 101; // 존재한다고 가정한 중카테고리 ID
      const result = service.findMinorCategories(mainId, subId);
      const expectedMinorCategories = CATEGORIES.mainCategory
        .find((cat) => cat.id === mainId)
        ?.subcategories.find((sub) => sub.id === subId)?.minorCategories;
      expect(result).toEqual(expectedMinorCategories);
    });

    it('존재하지 않는 대카테고리 ID에 대해 BadRequestException을 던진다', () => {
      const mainId = 999; // 존재하지 않는다고 가정한 대카테고리 ID
      const subId = 1; // 중카테고리 ID
      expect(() => service.findMinorCategories(mainId, subId)).toThrow(
        BadRequestException,
      );
    });

    it('존재하지 않는 중카테고리 ID에 대해 BadRequestException을 던진다', () => {
      const mainId = 1; // 대카테고리 ID
      const subId = 999; // 존재하지 않는다고 가정한 중카테고리 ID
      expect(() => service.findMinorCategories(mainId, subId)).toThrow(
        BadRequestException,
      );
    });
  });
});
