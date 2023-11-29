import { IsIn, IsNumber, IsOptional } from 'class-validator';
import { validIds } from '../const/valid-ids.const';

export class categoryIdDto {
  @IsNumber()
  @IsOptional()
  @IsIn(validIds.subCategoryIds, {
    message: '올바른 중 카테고리 ID가 아닙니다.',
  })
  subcategoryId?: number;

  @IsNumber()
  @IsOptional()
  @IsIn(validIds.minorCategoryIds, {
    message: '올바른 소 카테고리 ID가 아닙니다.',
  })
  minorCategoryId?: number;
}
