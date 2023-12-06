import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from '../auth.service';

/**
 * 엑세스 토큰을 검증하는 Guard
 * 엑세스 토큰이 없거나, 잘못된 경우 오류를 발생시킴
 * 엑세스 토큰이 유효한 경우 요청 객체에 userId 필드를 추가함
 */
@Injectable()
export class AccessTokenGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();
    const url = req.url;

    // /auth 경로에 대한 요청은 Guard를 적용하지 않음
    if (url.startsWith('/auth')) {
      return true;
    }

    // /admin 경로에 대한 요청은 Guard를 적용하지 않음 (배포시 제거해야함)
    if (url.startsWith('/admin')) {
      return true;
    }

    // 요청 헤더에서 'authorization' 필드를 추출
    const rawToken = req.headers['authorization'];
    // 토큰이 없는 경우 UnauthorizedException 발생
    if (!rawToken) {
      throw new UnauthorizedException('토큰이 없습니다.');
    }
    // AuthService를 사용하여 토큰에서 필요한 정보 추출
    const token = this.authService.extractTokenFromHeader(rawToken);
    const result = await this.authService.verifyToken(token);

    // 토큰이 refresh 토큰인 경우 오류 발생
    if (result.tokenType === 'refresh') {
      throw new UnauthorizedException('엑세스 토큰이 아닙니다.');
    }

    // 사용자 ID 추출 및 검증
    const userId = result?.userId;
    if (!userId) {
      throw new UnauthorizedException('엑세스 토큰이 잘못되었습니다.');
    }
    // 요청 객체에 userId 추가
    req.userId = userId;

    return true;
  }
}
