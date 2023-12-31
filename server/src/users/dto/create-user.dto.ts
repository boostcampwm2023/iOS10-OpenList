import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { ProviderType } from '../entities/user.entity';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  providerId: string;

  @IsEnum(ProviderType)
  @IsNotEmpty()
  provider: ProviderType;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  fullName: string;

  @IsString()
  @IsOptional()
  nickname?: string;
}
