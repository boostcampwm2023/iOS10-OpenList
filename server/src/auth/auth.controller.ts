import { Body, Controller, Headers, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { loginUserDto } from './dto/login-user.dto';
import { registerUserDto } from './dto/register-user.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * 이메일과 프로바이더를 통해 로그인한다. (개발자용)
   * @param user {loginUserDto}
   * @returns {accessToken,refreshAccessToken}
   */
  @Post('login')
  async postLogin(@Body() user: loginUserDto) {
    return await this.authService.loginWithEmailAndProvider(user);
  }

  /**
   * refresh 토큰을 통해 access 토큰을 재발급한다.
   * @param rawToken
   * @returns {accessToken}
   */
  @Post('token/access')
  postAccessToken(@Headers('authorization') rawToken: string) {
    const token = this.authService.extractTokenFromHeader(rawToken);
    return this.authService.refreshAccessToken(token);
  }

  /**
   * 이메일과 프로바이더를 통해 회원가입한다. (개발자용)
   * @param user {registerUserDto}
   * @returns {accessToken,refreshAccessToken}
   */
  @Post('register')
  postRegister(@Body() user: registerUserDto) {
    return this.authService.registerUser(user);
  }
}
