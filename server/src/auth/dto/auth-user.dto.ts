import {
  IsString,
  IsEmail,
  IsNotEmpty,
  ValidateNested,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';

class NameDto {
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;
}

export class UserDto {
  @IsEmail()
  email: string;

  @ValidateNested()
  @Type(() => NameDto)
  name: NameDto;
}

export class AuthUserDto {
  @IsString()
  @IsNotEmpty()
  authorizationCode: string;

  @IsString()
  @IsNotEmpty()
  idToken: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => UserDto)
  user?: UserDto;
}
