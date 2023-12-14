import pg from 'pg';
const { Pool } = pg;

import dotenv from 'dotenv';

dotenv.config({ path: '.env' });

export const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
});

export const saveData = async (checklistItems, category) => {
  const [main, sub, minor, categoryId] = category; // categoryId를 추가로 받습니다.
  const client = await pool.connect();

  try {
    for (const [key, value] of Object.entries(checklistItems)) {
      const queryText =
        'INSERT INTO ai_checklist_item_model("content", "categoryId") VALUES($1, $2)';

      await client.query(queryText, [value, categoryId]); // categoryId를 사용하여 쿼리 실행
    }
  } catch (error) {
    console.error('Error during database query execution:', error);
    throw error;
  } finally {
    client.release();
    console.log('Data saved successfully');
  }
};
