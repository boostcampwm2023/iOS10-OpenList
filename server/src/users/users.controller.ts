import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  postUser(@Body() createUserDto: CreateUserDto) {
    return this.usersService.createUser(createUserDto);
  }

  @Get()
  getUsers() {
    return this.usersService.findAllUsers();
  }

  @Get(':userId')
  getUser(@Param('userId') userId: number) {
    return this.usersService.findUserById(userId);
  }

  @Put(':userId')
  putUser(
    @Param('userId') userId: number,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateUser(userId, updateUserDto);
  }

  @Delete(':userId')
  deleteUser(@Param('userId') userId: number) {
    return this.usersService.removeUser(userId);
  }
}
