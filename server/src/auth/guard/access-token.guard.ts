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
    // if (url.startsWith('/admin')) {
    //   return true;
    // }

    let token;
    // 헤더 또는 쿠키에서 토큰 추출
    if (req.headers.authorization) {
      token = this.authService.extractTokenFromHeader(
        req.headers.authorization,
      );
    } else if (req.cookies && req.cookies['accessToken']) {
      // 쿠키에서 엑세스 토큰을 가져옴
      token = req.cookies['accessToken'];
    }

    // 토큰이 없는 경우 예외 발생
    if (!token) {
      throw new UnauthorizedException('토큰이 없습니다.');
    }
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
