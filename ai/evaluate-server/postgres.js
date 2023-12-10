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

async function getAllChecklistItems() {
  const now = new Date();
  const query = `SELECT * FROM ${items} JOIN ${category} ON ${items}.category_id = ${category}.id`;
  const result = await pool.query(query);
  console.log("result.rows:", result.rows);
  console.log("time seconds:", (new Date() - now) / 1000);

  return result.rows;
}

async function getAllCategories() {
  const query = `SELECT * FROM ${category}`;
  const result = await pool.query(query);

  const categories = result.rows;
  return categories;
}
async function getMinMaxEvaluatesByCategory() {
  const query = `
    SELECT 
      ${category}.id AS category_id,
      mainCategory,
      subCategory,
      minorCategory,
      MIN(${items}.evaluated_count_by_naver_ai) AS min_evaluate_count,
      MAX(${items}.evaluated_count_by_naver_ai) AS max_evaluate_count
    FROM ${items}
    JOIN ${category} ON ${items}.category_id = ${category}.id
    GROUP BY ${category}.id, mainCategory, subCategory, minorCategory;
  `;

  const result = await pool.query(query);
  console.log("Min and Max evaluates by category:", result.rows);

  return result.rows;
}

async function getChecklistItemsByCategoryAndEvaluateCount(categoryId) {
  const query = `
    SELECT * FROM ${items} 
    join ${category} on ${items}.category_id = ${category}.id
    WHERE category_id = ${categoryId} and evaluated_count_by_naver_ai < 5;
  `;
  const result = await pool.query(query);
  console.log("result.rows:", result.rows);
  return result.rows;
}

async function getChecklistItemsByEvaluateCount(evaluateCount) {
  const query = `
    SELECT ${items}.id AS item_id, *, ${evaluateCount} - evaluated_count_by_naver_ai AS diff
    FROM ${items} 
    LEFT JOIN ${category} ON ${items}.category_id = ${category}.id
    WHERE evaluated_count_by_naver_ai < ${evaluateCount}
    ORDER BY item_id;
  `;
  const result = await pool.query(query);
  console.log("result.rows:", result.rows);
  return result.rows;
}

const arrayToObj = (array) => {
  return array.reduce((obj, item) => {
    obj[item.id] = item.content;
    return obj;
  }, {});
};

// async function incrementCounts(ids, type) {
//   const column =
//     type === "selected"
//       ? "selected_count_by_naver_ai"
//       : "evaluated_count_by_naver_ai";
//   const idListString = ids.join(", ");
//   const query = `
//     UPDATE ${items}
//     SET ${column} = ${column} + 1
//     WHERE id IN (${idListString});
//   `;
//   try {
//     const result = await pool.query(query);
//     console.log(result.rowCount, "rows were updated");
//   } catch (error) {
//     console.error("Error updating counts:", error);
//   }
// }

// async function updateReasons(reasons) {
//   // Start a transaction
//   await pool.query("BEGIN");

//   try {
//     for (const [id, reason] of Object.entries(reasons)) {
//       const query = `UPDATE ${reasonTable} SET reason = $1 WHERE ai_checklist_items_id = $2;`;
//       await pool.query(query, [reason, id]);
//     }
//     // Commit the transaction if all updates are successful
//     await pool.query("COMMIT");
//     console.log("All reasons were updated successfully.");
//   } catch (error) {
//     // If there's an error, roll back the transaction
//     await pool.query("ROLLBACK");
//     console.error("Error occurred during reasons update:", error);
//   }
// }

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
  try {
    // console.log("query:", query);
    const result = await pool.query(query);
    // console.log("rows were updated", type, result);
  } catch (error) {
    console.error("Error updating counts:", error);
  }
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
  getAllChecklistItems,
  getAllCategories,
  getMinMaxEvaluatesByCategory,
  getChecklistItemsByCategoryAndEvaluateCount,
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  pool,
};
