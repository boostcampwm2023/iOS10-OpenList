import { Controller, Get, Inject, Query, Req, Res } from '@nestjs/common';
import { Response } from 'express';
import { RedisClientType } from 'redis';

@Controller('admin')
export class AdminController {
  constructor(
    @Inject('REDIS_SUB_CLIENT')
    private readonly redisSubscriber: RedisClientType,
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
  ) {}

  @Get('events')
  sse(
    @Req() req,
    @Res() res: Response,
    @Query('channels') channelsQuery: string,
  ) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    // 클라이언트 연결 초기화
    res.write(`data: Connection established\n\n`);

    const channels = channelsQuery.split(',');

    // Callback function
    const messageHandler = (message) => {
      console.log(message);
      res.write(`data: ${message}\n\n`);
    };

    // Subscribe to each channel with the callback
    channels.forEach((channel) => {
      this.redisSubscriber.subscribe(channel, messageHandler);
    });
    // 클라이언트 연결 종료 시 이벤트 처리
    req.on('close', () => {
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
