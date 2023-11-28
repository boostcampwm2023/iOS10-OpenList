import { IsNotEmpty, IsString } from 'class-validator';

const mainCategories = [
  //체크리스트 대 카테고리
  '일상',
  '여행',
  '취미',
  '공부',
  '운동',
  '기타',
];

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
