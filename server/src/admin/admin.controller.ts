import { Controller, Get, Inject, Req, Res } from '@nestjs/common';
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
  sse(@Req() req, @Res() res: Response) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    const changeFormat = (channel, message) => {
      const result = { channel, message };
      return JSON.stringify(result);
    };

    res.write(`data: ${changeFormat('notice', 'Server connected')}\n\n`);
    const channels = ['channel', 'sharedChecklist', 'ai_result'];
    channels.forEach((channel) => {
      this.redisSubscriber.subscribe(channel, (message) => {
        res.write(`data: ${changeFormat(channel, message)}\n\n`);
      });
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
