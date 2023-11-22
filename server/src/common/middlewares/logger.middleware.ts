import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private readonly logger = WinstonModule.createLogger(winstonConfig);

  use(req: Request, res: Response, next: NextFunction) {
    // 요청 객체로부터 ip, http method, url, user agent를 받아온 후
    const { ip, method, originalUrl } = req;
    const userAgent = req.get('user-agent');

    // 응답이 끝나는 이벤트가 발생하면 로그를 찍는다.
    res.on('finish', () => {
      const { statusCode } = res;
      this.logger.log({
        level: 'info',
        message: `${method} ${originalUrl} ${statusCode} ${ip} ${userAgent}`,
      });
    });

    next();
  }
}
