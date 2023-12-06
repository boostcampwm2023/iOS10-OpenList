import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { WsAdapter } from '@nestjs/platform-ws';
import { AppModule } from './app.module';
import { AuthService } from './auth/auth.service';
import { AccessTokenGuard } from './auth/guard/access-token.guard';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  //cors 설정
  app.enableCors({
    origin: ['http://127.0.0.1:5500', 'http://localhost:8080'],
  });
  // AccessTokenGuard 전역 Guard로 설정
  const authService = app.get(AuthService);
  app.useGlobalGuards(new AccessTokenGuard(authService));

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
  app.useWebSocketAdapter(new WsAdapter(app));

  const port = process.env.PORT || 3000; // 환경 변수에서 포트를 가져오거나 기본값으로 3000 사용
  await app.listen(port);
  console.log(`Application is running on: ${await app.getUrl()}`);
}

bootstrap();
