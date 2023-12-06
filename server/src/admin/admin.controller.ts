import { Controller, Get, Req, Res } from '@nestjs/common';
import { Response } from 'express';
import { RedisService } from 'redis/redis.service';
import { channels } from './const/channels.const';

@Controller('admin')
export class AdminController {
  constructor(private readonly redisService: RedisService) {}

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
    channels.forEach((channel) => {
      // this.redisSubscriber.subscribe(channel, (message) => {
      //   res.write(`data: ${changeFormat(channel, message)}\n\n`);
      // });
      this.redisService.subscribeToChannel(channel, (message) => {
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
    // this.redisPublisher.publish('channel', 'processAiResult');
    this.redisService.publishToChannel('channel', 'processAiResult');
  }

  @Get('category')
  category() {
    // this.redisPublisher.publish('channel', 'processCategory');
    this.redisService.publishToChannel('channel', 'processCategory');
  }
}