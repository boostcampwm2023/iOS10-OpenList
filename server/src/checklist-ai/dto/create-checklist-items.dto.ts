import { IsNotEmpty, IsString } from 'class-validator';

export class CreateChecklistItemsDto {
  // mainCategory에 있는 값은 mainCategories에 있는 값만 들어올 수 있도록
  // @IsIn(mainCategories)
  @IsString()
  @IsNotEmpty()
  mainCategory: string;

  @IsString()
  @IsNotEmpty()
  subCategory: string;

  @IsString()
  @IsNotEmpty()
  minorCategory: string;
}
