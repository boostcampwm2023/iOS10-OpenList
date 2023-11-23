import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { ProviderType } from '../entities/user.entity';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @IsNotEmpty()
  provider: ProviderType;

  @IsString()
  @IsNotEmpty()
  nickname: string;
}
