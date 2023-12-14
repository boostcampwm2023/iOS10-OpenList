import { RedisPub } from './redis-pub.js';
import { pool } from './gpt-data-saver.js';

async function getCategoriesInRange(minId, maxId) {
  const client = await pool.connect();
  try {
    const queryText =
      'SELECT * FROM category_model WHERE "categoryId" BETWEEN $1 AND $2';
    const res = await client.query(queryText, [minId, maxId]);

    // 쿼리 결과를 [mainCategory, subCategory, minorCategory] 형태로 변환
    const categories = res.rows.map((row) => [
      row.mainCategory,
      row.subCategory,
      row.minorCategory,
      row.categoryId,
    ]);
    return categories;
  } catch (error) {
    console.error('Error during database query execution:', error);
    throw error;
  } finally {
    client.release();
  }
}

async function main() {
  const minId = 1; // 최소 ID
  const maxId = 4; // 최대 ID

  const categoriesInRange = await getCategoriesInRange(minId, maxId);
  console.log('categoriesInRange:', categoriesInRange);

  // 들어가는 형태는 아래와 같다.
  // categoriesInRange: [
  //   [ '활동', '자기계발', '프로그래밍', 1 ],
  //   [ '활동', '자기계발', '취미 개발', 2 ],
  //   [ '활동', '레저 스포츠', '등산', 3 ],
  //   [ '활동', '레저 스포츠', '서핑', 4 ]
  // ]

  // redis pub/sub 테스트
  const redisPub = new RedisPub();
  redisPub.send(
    'ai_generate',
    JSON.stringify({
      messageData: 'generateGptData',
      categories: categoriesInRange,
    }),
  );
}

main();
