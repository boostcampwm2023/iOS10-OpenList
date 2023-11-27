import { Body, Controller, Headers, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { loginUserDto } from './dto/login-user.dto';
import { registerUserDto } from './dto/register-user.dto';
import { AuthUserDto } from './dto/auth-user.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Apple 로그인/등록을 처리한다.
   * @param dto {AuthUserDto}
   * @returns {accessToken, refreshToken}
   */
  @Post('apple/login')
  async postAppleLogin(
    @Body() dto: AuthUserDto,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    return await this.authService.registerOrLoginWithApple(dto);
  }

  /**
   * 이메일과 프로바이더를 통해 로그인한다. (개발자용)
   * @param user {loginUserDto}
   * @returns {accessToken,refreshToken}
   */
  @Post('login')
  async postLogin(@Body() user: loginUserDto) {
    return await this.authService.loginWithEmailAndProvider(user);
  }

  /**
   * refresh 토큰을 통해 access 토큰과 refresh 토큰을 재발급한다
   * @param rawToken
   * @returns {accessToken, refreshToken}
   */
  @Post('token/access')
  postAccessToken(
    @Headers('authorization') rawToken: string,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const token = this.authService.extractTokenFromHeader(rawToken);
    return this.authService.refreshAccessToken(token);
  }

  /**
   * 이메일과 프로바이더를 통해 회원가입한다. (개발자용)
   * @param user {registerUserDto}
   * @returns {accessToken,refreshToken}
   */
  @Post('register')
  postRegister(@Body() user: registerUserDto) {
    return this.authService.registerUser(user);
  }
}
