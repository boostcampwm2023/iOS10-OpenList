import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { loginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  postLogin(@Body() user: loginDto) {
    return this.authService.loginWithEmailAndProvider(user);
  }
}
