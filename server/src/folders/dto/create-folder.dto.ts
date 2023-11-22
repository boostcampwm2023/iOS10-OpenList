import { IsNotEmpty, IsString } from 'class-validator';

export class CreateFolderDto {
  // 길이 제한 필요
  @IsString()
  @IsNotEmpty()
  title: string;
}
