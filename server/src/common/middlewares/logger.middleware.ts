import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private readonly logger = WinstonModule.createLogger(winstonConfig);

  use(req: Request, res: Response, next: NextFunction) {
    const startTime = Date.now(); // 요청 시작 시간을 현재 시간으로 설정
    req['startTime'] = startTime; // startTime을 req 객체에 저장
    req['reqBody'] = req.body; // 요청 본문을 req 객체에 저장

    next();
  }
}
