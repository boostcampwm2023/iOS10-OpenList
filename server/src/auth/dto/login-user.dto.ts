import { PickType } from '@nestjs/mapped-types';
import { registerUserDto } from './register-user.dto';

export class loginUserDto extends PickType(registerUserDto, [
  'email',
  'provider',
]) {}
