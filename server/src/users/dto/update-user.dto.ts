import { PartialType, PickType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
class PartialCreateUserDto extends PickType(CreateUserDto, [
  'email',
  'fullName',
]) {}

export class UpdateUserDto extends PartialType(PartialCreateUserDto) {}
