import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UsersModel } from './entities/user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UsersModel)
    private readonly usersRepository: Repository<UsersModel>,
  ) {}
  async create(createUserDto: CreateUserDto) {
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

  findAll() {
    return `This action returns all users`;
  }

  findOne(id: number) {
    return `This action returns a #${id} user`;
  }

  update(id: number, updateUserDto: UpdateUserDto) {
    return `This action updates a #${id} user`;
  }

  remove(id: number) {
    return `This action removes a #${id} user`;
  }
}
