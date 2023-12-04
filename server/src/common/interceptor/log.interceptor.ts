import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { WinstonModule } from 'nest-winston';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = WinstonModule.createLogger(winstonConfig);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const ctx = context.switchToHttp();
    const request = ctx.getRequest();
    const response = ctx.getResponse();
    const startTime = request['startTime'];
    const reqBody = request['reqBody'];

    return next.handle().pipe(
      tap((data) => {
        const endTime = Date.now();
        const duration = endTime - startTime;
        const { method, originalUrl, ip } = request;
        const { statusCode } = response;
        const startTimeString = new Date(startTime).toLocaleString('ko-KR', {
          timeZone: 'Asia/Seoul',
        });

        this.logger.log({
          level: 'info',
          message: `${startTimeString} - ${method} ${originalUrl} - Status: ${statusCode} - IP: ${ip} - Duration: ${duration}ms - Request Body: ${JSON.stringify(
            reqBody,
          )} - Response Body: ${JSON.stringify(data)}`,
        });
      }),
    );
  }
}
