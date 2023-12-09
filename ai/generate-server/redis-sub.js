import redis from 'redis';
import { RedisPub } from './redis-pub.js';
import { PromisePool } from '@supercharge/promise-pool';
import dotenv from 'dotenv';
import { generateGptData } from './generate-server.js';
import { saveData } from './gpt-data-saver.js';

dotenv.config({ path: '.env' });

const subscriber = redis.createClient({
  url: process.env.REDIS_URL,
});

/**
 * 카테고리를 받아서 gpt-4로 데이터 생성 후 postgres에 저장
 * @param category
 * @returns {Promise<void>}
 */
async function processCategory(category) {
  try {
    const checklistItems = await generateGptData(category);
    await saveData(checklistItems, category);
  } catch (error) {
    console.error(`Error processing category ${category}:`, error);
  }
}

/**
 * redis pub/sub을 통해 promise pool 방식으로 카테고리를 받아서 gpt-4로 데이터 생성 후 postgres에 저장
 * @returns {Promise<void>}
 */
async function init() {
  const publisher = new RedisPub();
  const redisSub = await subscriber.connect();

  redisSub.subscribe('category', async function (message) {
    console.log('message:', message);

    const parsedMessage = JSON.parse(message);

    if (parsedMessage.messageData === 'generateGptData') {
      const { messageData, categories } = parsedMessage;
      console.log('messageData:', messageData);
      console.log('categories:', categories);

      console.log('start');

      // promise pool 방식으로 processCategory 함수 실행
      const { results, errors } = await PromisePool.withConcurrency(5)
        .for(categories)
        .process(async (category) => {
          await processCategory(category);
        });

      // 오류 처리 또는 결과 확인
      if (errors.length) {
        console.error('Errors:', errors);
      }

      console.log('end');
    }
  });
}

init();
