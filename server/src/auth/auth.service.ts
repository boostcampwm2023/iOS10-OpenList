import { Injectable, UnauthorizedException } from '@nestjs/common';
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

  /**
   * 토근을 검증한다. 검증에 실패하면 UnauthorizedException을 발생시킨다.
   * @param token
   * @returns 토근에 담긴 정보
   */
  verifyToken(token: string) {
    try {
      return this.jwtService.verify(token, {
        secret: process.env.JWT_SECRET,
      });
    } catch (error) {
      throw new UnauthorizedException('토큰이 만료되었거나 잘못된 토큰입니다.');
    }
  }

  /**
   * refresh 토큰을 통해 access 토큰을 재발급한다.
   * @param refreshToken
   * @returns 새로 발급된 access 토큰
   */
  refreshAccessToken(refreshToken: string) {
    const payload = this.verifyToken(refreshToken);
    if (payload.tokenType !== 'refresh') {
      throw new Error('access토큰 재발급은 refresh 토큰으로만 가능합니다.');
    }
    return this.signToken({ ...payload }, 'access');
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
