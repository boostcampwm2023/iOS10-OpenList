import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { CategoriesService } from './categories.service';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get('main-categories')
  getMainCategories() {
    return this.categoriesService.findMainCategories();
  }

  @Get(':mainId/sub-categories')
  getSubCategories(@Param('mainId') mainId: number) {
    return this.categoriesService.findSubCategories(mainId);
  }

  @Get(':mainId/sub-categories/:subId/minor-categories')
  getMinorCategories(
    @Param('mainId') mainId: number,
    @Param('subId') subId: number,
  ) {
    return this.categoriesService.findMinorCategories(mainId, subId);
  }
}
