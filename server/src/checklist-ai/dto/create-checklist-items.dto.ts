import { IsNotEmpty, IsString } from 'class-validator';

export class CreateChecklistItemsDto {
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
