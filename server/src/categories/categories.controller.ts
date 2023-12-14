import { Controller, Get, Query } from '@nestjs/common';
import { CategoriesService } from './categories.service';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get('main-categories')
  getMainCategories() {
    return this.categoriesService.findMainCategories();
  }

  @Get('/sub-categories')
  getSubCategories(@Query('mainCategory') mainCategory: string) {
    return this.categoriesService.findSubCategories(mainCategory);
  }

  @Get('minor-categories')
  getMinorCategories(
    @Query('mainCategory') mainCategory: string,
    @Query('subCategory') subCategory: string,
  ) {
    return this.categoriesService.findMinorCategories(
      mainCategory,
      subCategory,
    );
  }
}
