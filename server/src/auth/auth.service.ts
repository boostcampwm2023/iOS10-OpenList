import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserModel } from 'src/users/entities/user.entity';
import { UsersService } from 'src/users/users.service';

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

  /**
   * user 정보를 통해 access,refresh 토큰을 발급 후 반환한다.
   * @param user
   * @returns { accessToken: string, refreshToken: string}
   */
  loginUser(user: Pick<UserModel, 'email' | 'id'>) {
    return {
      accessToken: this.signToken(user, 'access'),
      refreshToken: this.signToken(user, 'refresh'),
    };
  }
}
