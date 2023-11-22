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
      throw new UnauthorizedException(
        'access토큰 재발급은 refresh 토큰으로만 가능합니다.',
      );
    }
    const accessToken = this.signToken({ ...payload }, 'access');
    return { accessToken };
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

  /**
   * 이메일과 provider를 통해 유저를 인증한다.
   * 없는 이메일이면 UnauthorizedException을 발생시킨다.
   * provider가 다르면 UnauthorizedException을 발생시키고 어떤 provider로 가입되어 있는지 알려준다.
   * @param user
   * @returns existUser
   */
  async authenticateWithEmailAndProvider(
    user: Pick<UserModel, 'email' | 'provider'>,
  ) {
    const existUser = await this.usersService.findUserByEmail(user.email);
    if (!existUser) {
      throw new UnauthorizedException('존재하지 않는 유저입니다.');
    }
    if (existUser.provider !== user.provider) {
      throw new UnauthorizedException(
        `해당 이메일은 ${user.provider}로 가입된 유저입니다.`,
      );
    }
    return existUser;
  }

  /**
   * 이메일과 provider를 통해 유저를 인증하고 토큰을 발급한다.
   * @param user
   * @returns { accessToken: string, refreshToken: string}
   */
  async loginWithEmailAndProvider(user: Pick<UserModel, 'email' | 'provider'>) {
    const existUser = await this.authenticateWithEmailAndProvider(user);
    return this.loginUser(existUser);
  }

  /**
   * 헤더에서 토큰을 추출한다.
   * @param header
   * @returns 토큰
   */
  extractTokenFromHeader(header: string) {
    // 정규식을 사용하여 'Bearer' 토큰 추출
    const bearerRegex = /^Bearer (.+)$/i;
    const match = header.match(bearerRegex);
    if (!match) {
      throw new UnauthorizedException('토큰이 올바르지 않습니다.');
    }
    // 매치된 그룹 중 첫 번째(토큰 부분)를 반환
    return match[1];
  }
}
