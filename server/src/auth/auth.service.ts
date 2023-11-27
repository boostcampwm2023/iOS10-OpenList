import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import axios from 'axios';
import * as fs from 'fs';
import * as jwt from 'jsonwebtoken';
import * as querystring from 'querystring';
import { CreateUserDto } from 'src/users/dto/create-user.dto';
import { ProviderType, UserModel } from 'src/users/entities/user.entity';
import { UsersService } from 'src/users/users.service';
import { AuthUserDto } from './dto/auth-user.dto';
import { loginUserDto } from './dto/login-user.dto';

type TokenType = 'access' | 'refresh';
@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Apple ID 토큰을 검증합니다.
   * @param idToken Apple ID 토큰
   // * @param expectedNonce 클라이언트에서 전달된 nonce 값
   */
  async verifyAppleIdToken(idToken: string): Promise<jwt.JwtPayload> {
    const decodedTokenHeader = jwt.decode(idToken, { complete: true }).header;

    // Apple 공개키 가져오기
    const applePublicKey = await this.getApplePublicKey(decodedTokenHeader.kid);

    // Apple ID 토큰 검증
    const decodedIdToken = jwt.verify(idToken, applePublicKey, {
      algorithms: ['RS256'],
    }) as jwt.JwtPayload;

    if (!decodedIdToken) {
      throw new UnauthorizedException('ID 토큰 디코드 오류');
    }

    // 'iss' 필드 검증
    if (decodedIdToken.iss !== 'https://appleid.apple.com') {
      throw new UnauthorizedException('잘못된 issuer');
    }

    // 'aud' 필드 검증
    if (decodedIdToken.aud !== process.env['SUB']) {
      throw new UnauthorizedException('잘못된 audience');
    }

    // // nonce 검증
    // if (decodedIdToken.nonce !== expectedNonce) {
    //   throw new UnauthorizedException('Nonce 값이 일치하지 않습니다.');
    // }

    return decodedIdToken;
  }

  /**
   * 애플 서버로부터 액세스 토큰과 리프레시 토큰을 받아옵니다.
   * @param authorizeCode 클라이언트로부터 받은 애플 인증 코드
   * @returns 애플로부터 받은 토큰들
   */
  async getAppleTokens(authorizeCode: string) {
    try {
      // 클라이언트 시크릿 생성
      const clientSecret = this.generateClientSecret();

      // 애플 서버에 토큰 요청
      const response = await axios.post(
        'https://appleid.apple.com/auth/token',
        querystring.stringify({
          grant_type: 'authorization_code',
          code: authorizeCode,
          client_secret: clientSecret,
          client_id: process.env['SUB'],
        }),
        {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        },
      );

      // 애플이 발급해준 access_token과 refresh_token 반환
      return {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        idToken: response.data.id_token,
      };
    } catch (error) {
      throw new UnauthorizedException(
        '애플 인증 과정에서 오류가 발생했습니다.',
      );
    }
  }

  async getApplePublicKey(kid: string): Promise<string> {
    try {
      const response = await axios.get('https://appleid.apple.com/auth/keys');
      const keys = response.data.keys;
      const matchingKey = keys.find((key) => key.kid === kid);

      if (!matchingKey) {
        throw new Error('Matching key not found.');
      }

      return matchingKey;
    } catch (error) {
      console.error('Apple public key 가져오기 실패:', error);
      throw new UnauthorizedException(
        'Apple public key를 가져오는데 실패했습니다.',
      );
    }
  }

  /**
   * 클라이언트 시크릿을 생성합니다.
   * @returns 생성된 클라이언트 시크릿
   */
  private generateClientSecret(): string {
    const algorithm = process.env['ALG'] as jwt.Algorithm; // 타입 캐스팅
    const keyid = process.env['KID'];
    const issuer = process.env['ISS'];
    const expiresIn = 15777000; // 6개월 (초 단위)
    const audience = 'https://appleid.apple.com';
    const subject = process.env['SUB'];
    const authKey = fs.readFileSync(process.env['AUTHKEY'], 'utf8');

    const signOptions: jwt.SignOptions = {
      algorithm: algorithm,
      keyid: keyid,
      issuer: issuer,
      audience: audience,
      subject: subject,
      expiresIn: expiresIn,
    };

    return jwt.sign({}, authKey, signOptions);
  }

  async registerOrLoginWithApple(
    authUserDto: AuthUserDto,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const { authorizationCode, user: userDto } = authUserDto;

    // 애플 서버로부터 액세스 토큰과 리프레시 토큰을 받아오기
    const appleTokens = await this.getAppleTokens(authorizationCode);

    if (!appleTokens.idToken) {
      throw new UnauthorizedException('ID 토큰이 없습니다.');
    }

    // Apple ID 토큰 검증
    const decodedIdToken = await this.verifyAppleIdToken(appleTokens.idToken);

    if (!decodedIdToken || typeof decodedIdToken === 'string') {
      throw new UnauthorizedException('애플 토큰 디코드 오류');
    }

    const fullName = `${userDto.name.firstName} ${userDto.name.lastName}`;
    let user = await this.usersService.findUserByAppleId(decodedIdToken.sub);

    if (!user) {
      user = await this.usersService.createAppleUser({
        providerId: decodedIdToken.sub,
        provider: ProviderType.APPLE,
        email: userDto.email,
        fullName,
      });
    } else if (userDto) {
      // entity가 존재하는데, user정보가 왔다면 업데이트
      user = await this.usersService.updateAppleUser(user.userId, {
        email: userDto.email,
        fullName,
      });
    }

    // 사용자에 대한 서비스의 JWT 토큰 생성
    return this.loginUser(user);
  }

  /**
   * 유저 정보를 통해 signToken()을 호출하여 access/refresh 토큰을 반환한다.
   * @param {UserModel} user
   * @returns {{accessToken: string, refreshToken: string}}
   */

  loginUser(user: UserModel): { accessToken: string; refreshToken: string } {
    const accessToken = this.signToken(user, 'access');
    const refreshToken = this.signToken(user, 'refresh');

    return { accessToken, refreshToken };
  }

  /**
   * 유저 정보를 통해 access/refresh 토큰을 발급한다.
   * @param user 유저 정보
   * @param tokenType 토큰 타입 (access/refresh)
   * @returns 토큰
   */
  signToken(user: UserModel, tokenType: TokenType) {
    const payload = {
      email: user.email,
      userId: user.userId,
      tokenType,
    };
    return this.jwtService.sign(payload, {
      secret: process.env['JWT_SECRET'],
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
        secret: process.env['JWT_SECRET'],
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
   * 이메일과 provider를 통해 유저를 인증한다.
   * 없는 이메일이면 UnauthorizedException을 발생시킨다.
   * provider가 다르면 UnauthorizedException을 발생시키고 어떤 provider로 가입되어 있는지 알려준다.
   * @param user
   * @returns existUser
   */
  async authenticateWithEmailAndProvider(user: loginUserDto) {
    const existUser = await this.usersService.findUserByEmail(user.email);
    if (!existUser) {
      throw new UnauthorizedException('존재하지 않는 유저입니다.');
    }
    if (existUser.provider !== user.provider) {
      throw new UnauthorizedException(
        `해당 이메일은 ${existUser.provider}로 가입된 유저입니다.`,
      );
    }
    return existUser;
  }

  /**
   * 이메일과 provider를 통해 유저를 인증하고 토큰을 발급한다.
   * @param user
   * @returns { accessToken: string, refreshToken: string}
   */
  async loginWithEmailAndProvider(user: loginUserDto) {
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

  /**
   * 이메일과 provider를 통해 유저를 등록하고 토큰을 발급한다.
   * @param user
   * @returns { accessToken: string, refreshToken: string}
   */
  async registerUser(user: CreateUserDto) {
    const newUser = await this.usersService.createUser(user);
    return this.loginUser(newUser);
  }
}
