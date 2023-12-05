import pg from 'pg';
const { Pool } = pg;

import dotenv from 'dotenv';

dotenv.config({ path: '.env' });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
});

export const saveData = async (checklistItems, category) => {
  const [main, sub, minor] = category;
  const client = await pool.connect();

  try {
    for (const [key, value] of Object.entries(checklistItems)) {
      const queryText =
        'INSERT INTO ai_checklist_items(content, mainCategory, subCategory, minorCategory) VALUES($1, $2, $3, $4)';

      await client.query(queryText, [value, main, sub, minor]);
    }
  } catch (error) {
    console.error('Error during database query execution:', error);
  } finally {
    client.release();
    console.log('Data saved successfully');
  }
};
