import { Inject, Injectable } from '@nestjs/common';
import { RedisClientType } from 'redis';

@Injectable()
export class RedisService {
  constructor(
    @Inject('REDIS_SUB_CLIENT')
    private readonly redisSubscriber: RedisClientType,
    @Inject('REDIS_PUB_CLIENT')
    private readonly redisPublisher: RedisClientType,
  ) {}

  subscribeToChannel(channel: string, callback: Function) {
    this.redisSubscriber.subscribe(channel, (message) => {
      callback(message);
    });
  }
  publishToChannel(channel: string, message: string) {
    this.redisPublisher.publish(channel, message);
  }
}
