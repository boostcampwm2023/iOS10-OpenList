import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { loginUserDto } from './dto/login-user.dto';

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
}
