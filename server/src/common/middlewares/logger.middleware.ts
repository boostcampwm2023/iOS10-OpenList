import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private readonly logger = WinstonModule.createLogger(winstonConfig);

  use(req: Request, res: Response, next: NextFunction) {
    const startTime = Date.now(); // 요청 시작 시간 기록
    const { ip, method, originalUrl } = req;
    const userAgent = req.get('user-agent');

    res.on('finish', () => {
      const duration = Date.now() - startTime; // 요청 처리 시간 계산
      const { statusCode } = res;
      this.logger.log({
        level: 'info',
        message: `${method} ${originalUrl} ${statusCode} ${ip} ${userAgent} - ${duration}ms`,
      });
    });

    next();
  }
}
