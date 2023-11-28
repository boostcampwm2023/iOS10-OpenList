import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from '../auth.service';

@Injectable()
export class AccessTokenGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();

    const url = req.url;

    // /auth 경로는 Guard를 적용하지 않음
    if (url.startsWith('/auth')) {
      return true;
    }

    // {authorization: 'Basic {token}'}
    const rawToken = req.headers['authorization'];
    if (!rawToken) {
      throw new UnauthorizedException('토큰이 없습니다.');
    }
    const token = this.authService.extractTokenFromHeader(rawToken);
    const result = await this.authService.verifyToken(token);
    if (result.tokenType === 'refresh') {
      throw new UnauthorizedException('엑세스 토큰이 아닙니다.');
    }
    const userId = result?.userId;
    if (!userId) {
      throw new UnauthorizedException('엑세스 토큰이 잘못되었습니다.');
    }
    req.userId = userId;

    return true;
  }
}
