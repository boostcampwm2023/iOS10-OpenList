import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserModel } from 'src/users/entities/user.entity';
import { UsersService } from 'src/users/users.service';
import { CreateAuthDto } from './dto/create-auth.dto';
import { UpdateAuthDto } from './dto/update-auth.dto';

type TokenType = 'access' | 'refresh';
@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * 유저 정보를 통해 access/refresh 토큰을 발급한다.
   * @param user 유저 정보
   * @param tokenType 토큰 타입 (access/refresh)
   * @returns 토큰
   */
  signToken(user: Pick<UserModel, 'email' | 'id'>, tokenType: TokenType) {
    const payload = {
      email: user.email,
      userID: user.id,
      tokenType: tokenType,
    };
    return this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET,
      expiresIn: tokenType === 'access' ? 300 : 3600,
    });
  }

  create(createAuthDto: CreateAuthDto) {
    return 'This action adds a new auth';
  }

  findAll() {
    return `This action returns all auth`;
  }

  findOne(id: number) {
    return `This action returns a #${id} auth`;
  }

  update(id: number, updateAuthDto: UpdateAuthDto) {
    return `This action updates a #${id} auth`;
  }

  remove(id: number) {
    return `This action removes a #${id} auth`;
  }
}
