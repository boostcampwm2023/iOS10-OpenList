const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

const ITEM_MODEL = "ai_checklist_item_model";
const CATEGORY_MODEL = "category_model";
const CATEGORY_ID = "categoryId";
const REASON_MODEL = "ai_checklist_item_naver_reason_model";
const AICHECKLISTITEMID = "aiChecklistItemId";
const AICHECKLISTITEMSID = "aiChecklistItemAiChecklistItemId";

async function getChecklistItemsByEvaluateCount(evaluateCount) {
  const query = `
    SELECT "${ITEM_MODEL}"."${AICHECKLISTITEMID}" AS item_id, *, ${evaluateCount} - evaluated_count_by_naver_ai AS diff
    FROM "${ITEM_MODEL}" 
    LEFT JOIN "${CATEGORY_MODEL}" ON "${ITEM_MODEL}"."${CATEGORY_ID}" = "${CATEGORY_MODEL}"."${CATEGORY_ID}"
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
    UPDATE "${ITEM_MODEL}"
    SET "${column}" = "${column}" + 1
    WHERE "${AICHECKLISTITEMID}" IN (${ids});
  `;
  await pool.query(query);
}

async function insertReasons(reasons) {
  const inserts = Object.entries(reasons).map(([id, reason]) =>
    pool.query(
      `INSERT INTO "${REASON_MODEL}" ("${AICHECKLISTITEMSID}", reason) VALUES ($1, $2);`,
      [id, reason]
    )
  );

  await Promise.all(inserts);
}

module.exports = {
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  pool,
};
