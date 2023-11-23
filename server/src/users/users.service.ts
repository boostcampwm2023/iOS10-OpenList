import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserModel } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserModel)
    private readonly usersRepository: Repository<UserModel>,
  ) {}
  async createUser(createUserDto: CreateUserDto) {
    const userObject = this.usersRepository.create(createUserDto);
    const emailExists = await this.usersRepository.exist({
      where: {
        email: createUserDto.email,
      },
    });
    if (emailExists) {
      throw new BadRequestException('이미 존재하는 이메일입니다.');
    }
    const newUser = await this.usersRepository.save(userObject);
    return newUser;
  }

  async findAllUsers() {
    const users = await this.usersRepository.find();
    return users;
  }

  async findUserById(id: number) {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new BadRequestException('존재하지 않는 유저입니다.');
    }
    return user;
  }

  async findUserByEmail(email: string) {
    const user = await this.usersRepository.findOne({ where: { email } });
    if (!user) {
      throw new BadRequestException('존재하지 않는 유저입니다.');
    }
    return user;
  }

  async updateUser(id: number, updateUserDto: UpdateUserDto) {
    const user = await this.findUserById(id);
    const updatedUser = await this.usersRepository.save({
      ...user,
      ...updateUserDto,
    });
    return updatedUser;
  }

  async removeUser(id: number) {
    const user = await this.findUserById(id);
    await this.usersRepository.remove(user);
    return { message: '삭제되었습니다.' };
  }
}
