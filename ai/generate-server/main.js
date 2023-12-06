import { generateGptData } from './generate-server.js';
import { saveData } from './gpt-data-saver.js';
// import { categories } from './category.const.js';
import { RedisPub } from './redis-pub.js';

async function main() {
  // 대량 데이터 생성
  // for (const category of categories) {
  //   const data = await generateGptData(category);
  //   await saveData(data, category);
  // }

  const category = ['자기관리', '운동', '벌크업'];
  // const data = await generateGptData(category);
  // await saveData(data, category);

  // redis pub/sub 테스트
  const redisPub = new RedisPub();
  redisPub.send(
    'category',
    JSON.stringify({
      messageData: 'generateGptData',
      category: category,
    }),
  );
}

main();
