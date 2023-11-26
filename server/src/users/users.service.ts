import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ProviderType, UserModel } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserModel)
    private readonly usersRepository: Repository<UserModel>,
  ) {}

  async findUserByAppleId(appleId: string): Promise<UserModel | undefined> {
    return await this.usersRepository.findOne({
      where: { providerId: appleId, provider: ProviderType.APPLE },
    });
  }

  async createAppleUser(dto: CreateUserDto): Promise<UserModel> {
    const userObj = this.usersRepository.create(dto);
    const emailExists = await this.usersRepository.exist({
      where: {
        email: dto.email,
      },
    });
    if (emailExists) {
      throw new BadRequestException('이미 존재하는 이메일입니다.');
    }
    const newUser = await this.usersRepository.save(userObj);
    return newUser;
  }

  async updateAppleUser(userId: number, dto: UpdateUserDto) {
    const user = await this.findUserById(userId);
    const updatedUser = await this.usersRepository.save({
      ...user,
      ...dto,
    });
    return updatedUser;
  }

  async findAllUsers() {
    const users = await this.usersRepository.find();
    return users;
  }

  async findUserById(userId: number) {
    const user = await this.usersRepository.findOne({ where: { userId } });
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

  async updateUser(userId: number, updateUserDto: UpdateUserDto) {
    const user = await this.findUserById(userId);
    const updatedUser = await this.usersRepository.save({
      ...user,
      ...updateUserDto,
    });
    return updatedUser;
  }

  async removeUser(userId: number) {
    const user = await this.findUserById(userId);
    await this.usersRepository.remove(user);
    return { message: '삭제되었습니다.' };
  }
}
