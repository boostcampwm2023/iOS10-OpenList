import { IsNotEmpty, IsString } from 'class-validator';
import { ProviderType } from 'src/users/entities/user.entity';

export class registerUserDto {
  @IsString()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  provider: ProviderType;

  @IsString()
  @IsNotEmpty()
  nickname: string;
}
