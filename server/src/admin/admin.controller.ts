import { Controller, Get, Inject, Req, Res } from '@nestjs/common';
import { Response } from 'express';
import { RedisClientType } from 'redis';
import { RedisService } from 'redis/redis.service';

@Controller('admin')
export class AdminController {
  constructor(
    @Inject('REDIS_SUB_CLIENT')
    private readonly redisSubscriber: RedisClientType,
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
    private readonly redisService: RedisService,
  ) {}

  @Get('events')
  sse(@Req() req, @Res() res: Response) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    this.redisService.subscribeToChannel('channel', (message) => {
      res.write(`data: ${message}\n\n`);
    });
    this.redisService.subscribeToChannel('sharedChecklist', (message) => {
      res.write(`data: ${message}\n\n`);
    });
    this.redisService.subscribeToChannel('ai_result', (message) => {
      res.write(`data: ${message}\n\n`);
    });

    req.on('close', () => {
      // 필요한 경우 연결 종료 시 처리 로직
      res.end();
    });
  }
  @Get('generate')
  generate() {
    this.redisPublisher.publish('channel', 'processAiResult');
  }

  @Get('category')
  category() {
    this.redisPublisher.publish('channel', 'processCategory');
  }
}
