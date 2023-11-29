import { Controller, Get, Param } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { categoryIdDto } from './dto/category-id.dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  getMainCategories() {
    return this.categoriesService.findMainCategories();
  }

  @Get(':subId/sub-categories')
  getSubCategories(@Param('subId') subId: categoryIdDto) {
    return this.categoriesService.findSubCategories(subId);
  }

  @Get(':subId/minor-categories/:minorId')
  getMinorCategories(@Param('minorId') minorId: categoryIdDto) {
    return this.categoriesService.findMinorCategories(minorId);
  }
}
