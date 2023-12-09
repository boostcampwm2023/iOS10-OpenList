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

  const categories = [
    ['활동', '자기계발', '프로그래밍'],
    ['활동', '자기계발', '취미 개발'],
    ['활동', '레저 스포츠', '등산'],
    ['활동', '레저 스포츠', '서핑'],
  ];
  // const data = await generateGptData(category);
  // await saveData(data, category);

  // redis pub/sub 테스트
  const redisPub = new RedisPub();
  redisPub.send(
    'category',
    JSON.stringify({
      messageData: 'generateGptData',
      categories: categories,
    }),
  );
}

main();
