import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class AuthUserDto {
  @IsString()
  @IsNotEmpty()
  identityToken: string;

  @IsOptional()
  @IsString()
  fullName?: string;
}
