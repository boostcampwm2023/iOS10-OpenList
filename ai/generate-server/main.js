import { generateGptData } from './generate-server.js';
import { saveData } from './gpt-data-saver.js';

async function main() {
  // const category = ['건강관리', '영양제 추천', '20대 남'];
  const category = ['준비물', '해외여행', '일본'];
  const data = await generateGptData(category);
  await saveData(data, category);
}

await main();
