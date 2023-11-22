import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { UserModel } from 'src/users/entities/user.entity';
import { UsersService } from 'src/users/users.service';
import { AuthService } from './auth.service';
import { loginUserDto } from './dto/login-user.dto';
import { registerUserDto } from './dto/register-user.dto';

describe('AuthService', () => {
  let authService: AuthService;
  let jwtService: JwtService;
  let usersService: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
            verify: jest.fn(),
          },
        },
        {
          provide: UsersService,
          useValue: {
            findUserByEmail: jest.fn(),
            createUser: jest.fn(),
          },
        },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    jwtService = module.get<JwtService>(JwtService);
    usersService = module.get<UsersService>(UsersService);
  });
  describe('signToken', () => {
    it('유저 정보로 access 토큰을 발급한다.', () => {
      const user = { email: 'test@example.com', id: 1 };
      const token = 'access_token';
      jest.spyOn(jwtService, 'sign').mockReturnValue(token);

      const result = authService.signToken(user, 'access');

      expect(jwtService.sign).toHaveBeenCalledWith(expect.anything(), {
        secret: process.env.JWT_SECRET,
        expiresIn: 300,
      });
      expect(result).toEqual(token);
    });

    it('유저 정보로 refresh 토큰을 발급한다.', () => {
      const user = { email: 'test@example.com', id: 1 };
      const token = 'refresh_token';
      jest.spyOn(jwtService, 'sign').mockReturnValue(token);

      const result = authService.signToken(user, 'refresh');

      expect(jwtService.sign).toHaveBeenCalledWith(expect.anything(), {
        secret: process.env.JWT_SECRET,
        expiresIn: 3600,
      });
      expect(result).toEqual(token);
    });
  });

  describe('verifyToken', () => {
    it('유효한 토큰을 검증한다.', () => {
      const token = 'valid_token';
      const payload = { email: 'test@example.com', userID: 1 };
      jest.spyOn(jwtService, 'verify').mockReturnValue(payload);

      const result = authService.verifyToken(token);

      expect(jwtService.verify).toHaveBeenCalledWith(token, expect.anything());
      expect(result).toEqual(payload);
    });

    it('유효하지 않은 토큰은 UnauthorizedException을 발생시킨다.', () => {
      jest.spyOn(jwtService, 'verify').mockImplementation(() => {
        throw new Error();
      });

      expect(() => authService.verifyToken('invalid_token')).toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('refreshAccessToken', () => {
    it('유효한 refresh 토큰으로 access 토큰을 재발급한다.', () => {
      const refreshToken = 'valid_refresh_token';
      const accessToken = 'new_access_token';
      jest
        .spyOn(authService, 'verifyToken')
        .mockReturnValue({ tokenType: 'refresh' });
      jest.spyOn(authService, 'signToken').mockReturnValue(accessToken);

      const result = authService.refreshAccessToken(refreshToken);

      expect(authService.verifyToken).toHaveBeenCalledWith(refreshToken);
      expect(authService.signToken).toHaveBeenCalledWith(
        expect.anything(),
        'access',
      );
      expect(result).toEqual({ accessToken });
    });

    it('access 토큰을 재발급하는데 refresh 토큰이 아닌 경우 UnauthorizedException을 발생시킨다.', () => {
      const invalidToken = 'invalid_refresh_token';
      jest
        .spyOn(authService, 'verifyToken')
        .mockReturnValue({ tokenType: 'access' });

      expect(() => authService.refreshAccessToken(invalidToken)).toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('loginUser', () => {
    it('유저 정보로 access 토큰과 refresh 토큰을 발급한다.', () => {
      const user = { email: 'test@example.com', id: 1 };
      const accessToken = 'access_token';
      const refreshToken = 'refresh_token';
      jest
        .spyOn(authService, 'signToken')
        .mockImplementation((user, tokenType) =>
          tokenType === 'access' ? accessToken : refreshToken,
        );

      const result = authService.loginUser(user);

      expect(authService.signToken).toHaveBeenCalledWith(user, 'access');
      expect(authService.signToken).toHaveBeenCalledWith(user, 'refresh');
      expect(result).toEqual({ accessToken, refreshToken });
    });
  });
  describe('authenticateWithEmailAndProvider', () => {
    it('유효한 이메일과 provider로 유저를 인증한다.', async () => {
      const user: loginUserDto = {
        email: 'test@example.com',
        provider: 'APPLE',
      };
      const existUser = { ...user, id: 1 } as UserModel;
      jest.spyOn(usersService, 'findUserByEmail').mockResolvedValue(existUser);

      const result = await authService.authenticateWithEmailAndProvider(user);

      expect(usersService.findUserByEmail).toHaveBeenCalledWith(user.email);
      expect(result).toEqual(existUser);
    });

    it('존재하지 않는 이메일이면 UnauthorizedException을 발생시킨다.', async () => {
      const user: loginUserDto = {
        email: 'nonexistent@example.com',
        provider: 'APPLE',
      };
      jest.spyOn(usersService, 'findUserByEmail').mockResolvedValue(null);

      await expect(
        authService.authenticateWithEmailAndProvider(user),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('provider가 다르면 UnauthorizedException을 발생시킨다.', async () => {
      const user: loginUserDto = {
        email: 'test@example.com',
        provider: 'GOOGLE',
      };
      const existUser = { ...user, provider: 'APPLE', id: 1 } as UserModel;
      jest.spyOn(usersService, 'findUserByEmail').mockResolvedValue(existUser);

      await expect(
        authService.authenticateWithEmailAndProvider(user),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('loginWithEmailAndProvider', () => {
    it('유효한 이메일과 provider로 로그인하고 토큰을 발급한다.', async () => {
      const user: loginUserDto = {
        email: 'test@example.com',
        provider: 'APPLE',
      };
      const existUser = { email: user.email, id: 1 } as UserModel;
      jest
        .spyOn(authService, 'authenticateWithEmailAndProvider')
        .mockResolvedValue(existUser);
      jest.spyOn(authService, 'loginUser').mockReturnValue({
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });

      const result = await authService.loginWithEmailAndProvider(user);

      expect(authService.authenticateWithEmailAndProvider).toHaveBeenCalledWith(
        user,
      );
      expect(authService.loginUser).toHaveBeenCalledWith(existUser);
      expect(result).toEqual({
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });
    });
  });

  describe('extractTokenFromHeader', () => {
    it('헤더에서 토큰을 추출한다.', () => {
      const header = 'Bearer valid_token';

      const result = authService.extractTokenFromHeader(header);

      expect(result).toEqual('valid_token');
    });

    it('헤더 형식이 잘못되었을 때 UnauthorizedException을 발생시킨다.', () => {
      const header = 'invalid_header';

      expect(() => {
        authService.extractTokenFromHeader(header);
      }).toThrow(UnauthorizedException);
    });
  });

  describe('registerUser', () => {
    it('유저를 등록하고 토큰을 발급한다.', async () => {
      const user: registerUserDto = {
        email: 'newuser@example.com',
        provider: 'APPLE',
        nickname: 'NewUser',
      };
      const newUser = { ...user, id: 3 } as UserModel;
      jest.spyOn(usersService, 'createUser').mockResolvedValue(newUser);
      jest.spyOn(authService, 'loginUser').mockReturnValue({
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });

      const result = await authService.registerUser(user);

      expect(usersService.createUser).toHaveBeenCalledWith(user);
      expect(authService.loginUser).toHaveBeenCalledWith(newUser);
      expect(result).toEqual({
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });
    });
  });
});
