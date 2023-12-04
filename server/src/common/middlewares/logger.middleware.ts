import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private readonly logger = WinstonModule.createLogger(winstonConfig);

  use(req: Request, res: Response, next: NextFunction) {
    const startTime = new Date(); // 현재 시간을 Date 객체로 얻기
    const startTimeString = startTime.toLocaleString('ko-KR', {
      timeZone: 'Asia/Seoul',
    }); // 한국 시간대로 변환
    const { ip, method, originalUrl } = req;
    const userAgent = req.get('user-agent');

    res.on('finish', () => {
      const duration = Date.now() - startTime.getTime(); // 요청 처리 시간 계산
      const { statusCode } = res;
      this.logger.log({
        level: 'info',
        message: `${startTimeString} - ${method} ${originalUrl} ${statusCode} ${ip} ${userAgent} - ${duration}ms`,
      });
    });

    next();
  }
}
