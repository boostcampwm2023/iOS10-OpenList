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
    const users = this.usersRepository.find();
    return users;
  }

  async findOne(id: number) {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new BadRequestException('존재하지 않는 유저입니다.');
    }
    return user;
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new BadRequestException('존재하지 않는 유저입니다.');
    }
    const updatedUser = await this.usersRepository.save({
      ...user,
      ...updateUserDto,
    });
    return updatedUser;
  }

  remove(id: number) {
    return `This action removes a #${id} user`;
  }
}
