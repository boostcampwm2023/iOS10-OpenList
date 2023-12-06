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
      this.redisService.subscribeToChannel(channel, (message) => {
        res.write(`data: ${changeFormat(channel, message)}\n\n`);
      });
    });

    req.on('close', () => {
      res.end();
    });
  }
  @Get('generate')
  generate() {
    this.redisService.publishToChannel('channel', 'processAiResult');
  }

  @Get('category')
  category() {
    this.redisService.publishToChannel('channel', 'processCategory');
  }
}
