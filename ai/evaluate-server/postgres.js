const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

const items = "ai_checklist_item_model2";
const category = "category_model2";
const reasonTable = "ai_checklist_items_naver_reason";

// async function getAllChecklistItems() {
//   const now = new Date();
//   const query = `SELECT * FROM ${items} JOIN ${category} ON ${items}.category_id = ${category}.id`;
//   const result = await pool.query(query);

//   return result.rows;
// }

// async function getAllCategories() {
//   const query = `SELECT * FROM ${category}`;
//   const result = await pool.query(query);

//   const categories = result.rows;
//   return categories;
// }
// async function getMinMaxEvaluatesByCategory() {
//   const query = `
//     SELECT
//       ${category}.id AS category_id,
//       mainCategory,
//       subCategory,
//       minorCategory,
//       MIN(${items}.evaluated_count_by_naver_ai) AS min_evaluate_count,
//       MAX(${items}.evaluated_count_by_naver_ai) AS max_evaluate_count
//     FROM ${items}
//     JOIN ${category} ON ${items}.category_id = ${category}.id
//     GROUP BY ${category}.id, mainCategory, subCategory, minorCategory;
//   `;

//   const result = await pool.query(query);
//   console.log("Min and Max evaluates by category:", result.rows);

//   return result.rows;
// }

// async function getChecklistItemsByCategoryAndEvaluateCount(categoryId) {
//   const query = `
//     SELECT * FROM ${items}
//     join ${category} on ${items}.category_id = ${category}.id
//     WHERE category_id = ${categoryId} and evaluated_count_by_naver_ai < 5;
//   `;
//   const result = await pool.query(query);
//   console.log("result.rows:", result.rows);
//   return result.rows;
// }

async function getChecklistItemsByEvaluateCount(evaluateCount) {
  const query = `
    SELECT ${items}.id AS item_id, *, ${evaluateCount} - evaluated_count_by_naver_ai AS diff
    FROM ${items} 
    LEFT JOIN ${category} ON ${items}.category_id = ${category}.id
    WHERE evaluated_count_by_naver_ai < ${evaluateCount}
    ORDER BY item_id;
  `;
  const result = await pool.query(query);
  return result.rows;
}

async function incrementCounts(ids, type) {
  const column =
    type === "selected"
      ? "selected_count_by_naver_ai"
      : "evaluated_count_by_naver_ai";

  const query = `
    UPDATE ${items}
    SET ${column} = ${column} + 1
    WHERE id IN (${ids});
  `;
  await pool.query(query);
}

async function insertReasons(reasons) {
  const inserts = Object.entries(reasons).map(([id, reason]) =>
    pool.query(
      `INSERT INTO ${reasonTable} (ai_checklist_items_id, reason) VALUES ($1, $2);`,
      [id, reason]
    )
  );

  await Promise.all(inserts);
}

module.exports = {
  // getAllChecklistItems,
  // getAllCategories,
  // getMinMaxEvaluatesByCategory,
  // getChecklistItemsByCategoryAndEvaluateCount,
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  pool,
};
