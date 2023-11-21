import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import * as express from 'express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(express.static(join(__dirname, '..', 'public')));
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true, // 요청에서 넘어온 자료들의 형변환을 자동으로 해줌
      transformOptions: {
        enableImplicitConversion: true, // true로 설정하면, 자동 형변환을 허용함
      },
      whitelist: true, // 데코레이터가 없는 속성들은 제거해줌
      forbidNonWhitelisted: true, // 데코레이터가 없는 속성이 있으면 요청 자체를 막아버림
    }),
  );
  await app.listen(3000);
}
bootstrap();
