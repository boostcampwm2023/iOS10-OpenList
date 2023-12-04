import { DynamicModule, Global, Module } from '@nestjs/common';
import { RedisClientType, createClient } from 'redis';

/**
 * RedisModule은 NestJS 애플리케이션에서 Redis 클라이언트를 설정하고 관리하는데 사용되는 모듈이다.
 */
@Global()
@Module({})
export class RedisModule {
  /**
   * forRoot 메서드는 Redis 클라이언트를 생성하고 초기화한다. 이 메서드는 DynamicModule을 반환한다.
   */
  static forRoot(): DynamicModule {
    /**
     * 일반적인 데이터 작업을 위한 Redis 클라이언트를 제공한다.
     */
    const redisProvider = {
      provide: 'REDIS_CLIENT',
      useFactory: async (): Promise<RedisClientType> => {
        const client = createClient({
          url: process.env.REDIS_URL, // Redis 서버의 URL
          // username: process.env.REDIS_USERNAME, // Redis 사용자 이름
          // password: process.env.REDIS_PASSWORD, // Redis 비밀번호
        }) as RedisClientType;
        await client.connect(); // 클라이언트 연결
        return client; // 연결된 클라이언트 반환
      },
    };

    /**
     * 메시지를 Redis 채널에 게시하는 데 사용되는 Redis 클라이언트를 제공한다.
     */
    const redisPubProvider = {
      provide: 'REDIS_PUB_CLIENT',
      useFactory: async (): Promise<RedisClientType> => {
        const client = createClient({
          url: process.env.REDIS_URL,
          // username: process.env.REDIS_USERNAME,
          // password: process.env.REDIS_PASSWORD,
        }) as RedisClientType;
        await client.connect();
        return client;
      },
    };

    /**
     * Redis 채널에서 메시지를 수신하는 데 사용되는 Redis 클라이언트를 제공한다.
     */
    const redisSubProvider = {
      provide: 'REDIS_SUB_CLIENT',
      useFactory: async (): Promise<RedisClientType> => {
        const client = createClient({
          url: process.env.REDIS_URL,
          // username: process.env.REDIS_USERNAME,
          // password: process.env.REDIS_PASSWORD,
        }) as RedisClientType;
        await client.connect();
        return client;
      },
    };

    /**
     * 모듈 구성을 반환한다. 여기에는 Redis 클라이언트 및 해당 클라이언트를 다른 모듈에서 주입하여 사용할 수 있도록 하는 설정이 포함되어 있다.
     */
    return {
      module: RedisModule,
      providers: [redisProvider, redisPubProvider, redisSubProvider],
      exports: [redisProvider, redisPubProvider, redisSubProvider],
    };
  }
}
