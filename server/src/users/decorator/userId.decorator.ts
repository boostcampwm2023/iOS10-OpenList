import {
  createParamDecorator,
  ExecutionContext,
  InternalServerErrorException,
} from '@nestjs/common';

/**
 * @UserId 커스텀 데코레이터
 * ExecutionContext로부터 HTTP 요청을 추출하고, 해당 요청에서 userId를 반환한다.
 * 이 데코레이터는 컨트롤러의 핸들러 메소드에서 사용되며, 인증된 사용자의 식별자를 제공한다.
 * 요청 객체에 사용자 정보가 없는 경우 InternalServerErrorException을 발생시킨다.
 */
export const UserId = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    if (!request.userId) {
      throw new InternalServerErrorException('사용자 정보가 없습니다.');
    }
    return request.userId;
  },
);
