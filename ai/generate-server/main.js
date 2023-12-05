import { generateGptData } from './generate-server.js';
import { saveData } from './gpt-data-saver.js';
import { categories } from './category.const.js';

async function main() {
  // 대량 데이터 생성
  // for (const category of categories) {
  //   const data = await generateGptData(category);
  //   await saveData(data, category);
  // }

  const category = ['식단', '건강식', '무첨가식품'];
  const data = await generateGptData(category);
  await saveData(data, category);
}

await main();
