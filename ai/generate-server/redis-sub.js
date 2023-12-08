import redis from 'redis';
import dotenv from 'dotenv';
dotenv.config({ path: '.env' });

import { generateGptData } from './generate-server.js';
import { saveData } from './gpt-data-saver.js';

import { RedisPub } from './redis-pub.js';

const subscriber = redis.createClient({
  host: 'localhost',
  port: 6379,
});

async function init() {
  const publisher = new RedisPub();
  const redisSub = await subscriber.connect();

  redisSub.subscribe('category', async function (message) {
    try {
      console.log('message:', message);

      const parsedMessage = JSON.parse(message);

      if (parsedMessage.messageData === 'generateGptData') {
        const { messageData, category } = parsedMessage;
        console.log('messageData:', messageData);
        console.log('category:', category);

        console.log('start');

        // generateGptData 함수 호출에 category 전달
        for (const category of categories) {
          const checklistItems = await generateGptData(category);
          console.log('checklistItems:', checklistItems);
          console.log('save to postgres');
          // saveData 함수 호출에 category 전달
          await saveData(checklistItems, category);
          console.log('finished');
        }
        // const checklistItems = await generateGptData(category);
        // console.log('checklistItems:', checklistItems);
        // console.log('save to postgres');
        // // saveData 함수 호출에 category 전달
        // await saveData(checklistItems, category);
        // console.log('finished');

        console.log('end');
      }
    } catch (error) {
      console.error(`Error while processing ${message}: `, error);
    }
  });
}

init();
