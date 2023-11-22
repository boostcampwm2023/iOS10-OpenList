import { IsNotEmpty, IsString } from 'class-validator';

export class loginUserDto {
  @IsString()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  provider: string;
}
