import {
  Controller,
  Get,
  Req,
  Res,
  UnauthorizedException,
} from '@nestjs/common';
import { Response } from 'express';
import { RedisService } from 'redis/redis.service';
import { UserId } from 'src/users/decorator/userId.decorator';

@Controller('admin')
export class AdminController {
  constructor(private readonly redisService: RedisService) {}

  @Get('events')
  sse(@Req() req, @Res() res: Response, @UserId() userId: number) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }

    const changeFormat = (channel, message) => {
      const result = { channel, message };
      return JSON.stringify(result);
    };

    res.write(`data: ${changeFormat('notice', 'Server connected')}\n\n`);

    this.redisService.psubscribeToPattern('*', (message, channel) => {
      res.write(`data: ${changeFormat(channel, message)}\n\n`);
      console.log(message, channel);
    });

    req.on('close', () => {
      res.end();
    });
  }
  @Get('generate')
  generate(@UserId() userId: number) {
    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }
    this.redisService.publishToChannel('channel', 'processAiResult');
  }

  @Get('category')
  category(@UserId() userId: number) {
    if (userId !== 1) {
      throw new UnauthorizedException('관리자가 아닙니다.');
    }
    this.redisService.publishToChannel('channel', 'processCategory');
  }
}
