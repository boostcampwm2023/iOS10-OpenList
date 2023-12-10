import {
  CallHandler,
  ExecutionContext,
  Inject,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { WinstonModule } from 'nest-winston';
import { RedisClientType } from 'redis';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { winstonConfig } from '../../utils/winston.config';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = WinstonModule.createLogger(winstonConfig);
  constructor(
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
  ) {}

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

        const message = `${startTimeString} - ${method} ${originalUrl} - Status: ${statusCode} - IP: ${ip} - Duration: ${duration}ms`;
        this.redisPublisher.publish(
          'httpLog',
          JSON.stringify({
            info: message,
            req: reqBody,
            res: data || {},
          }),
        );

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
