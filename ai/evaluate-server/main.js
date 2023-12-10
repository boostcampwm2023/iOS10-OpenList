const {
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  pool,
} = require("./postgres.js");
const { PromisePool } = require("@supercharge/promise-pool");

const { processAiResult } = require("./evaluate-api.js");
async function main() {
  try {
    const checklistItemsByEvaluateCount =
      await getChecklistItemsByEvaluateCount(100);
    const result = transformAndChunkItems(checklistItemsByEvaluateCount);
    console.log("expected count: ", result.length);
    console.log("result:", result);

    await processResultsSequentially(result); // 작업이 완료될 때까지 기다림
    console.log("모든 처리가 완료되었습니다.");
  } catch (error) {
    console.error("An error occurred:", error);
  } finally {
    await pool.end(); // 모든 작업이 끝난 후 연결 풀을 닫음
  }
}

function transformAndChunkItems(items, chunkSize = 10) {
  const categoryMap = {};

  // Group items by category_id
  items.forEach((item) => {
    if (!categoryMap[item.category_id]) {
      categoryMap[item.category_id] = {
        category: {
          maincategory: item.maincategory,
          subcategory: item.subcategory,
          minorcategory: item.minorcategory,
        },
        contents: [],
      };
    }
    categoryMap[item.category_id].contents.push({
      [item.item_id]: item.content,
    });
  });

  // Chunk items within each category
  const result = [];
  Object.values(categoryMap).forEach((cat) => {
    for (let i = 0; i < cat.contents.length; i += chunkSize) {
      const chunk = cat.contents.slice(i, i + chunkSize);
      result.push({
        category: cat.category,
        contents: Object.assign({}, ...chunk),
      });
    }
  });

  return result;
}

async function processResultsSequentially(result) {
  let successCount = 0;
  let failureCount = 0;

  const { results, errors } = await PromisePool.withConcurrency(10) // 동시에 처리할 작업 수를 5개로 설정
    .for(result)
    .process(async (item) => {
      const { category, contents } = item;
      const contentIDs = Object.keys(contents);
      const { select, reason } = await processAiResult(category, contents);

      if (select === undefined || reason === undefined) {
        failureCount++;
        console.log("Failure:", failureCount);
      } else {
        try {
          await incrementCounts(contentIDs, "evaluated");
          await incrementCounts(Object.keys(reason), "selected");
          await insertReasons(reason);
          successCount++;
          console.log("Success:", successCount);
        } catch (error) {
          failureCount++;
          console.log("Failure:", failureCount);
        }
      }
    });

  // 오류 로그
  if (errors.length) {
    console.log("Errors:", errors);
  }
}
async function processResultsSequentiallySlow(result) {
  let successCount = 0;
  let failureCount = 0;
  const contentIDsObj = [];

  for (const item of result) {
    const { category, contents } = item;
    const contentIDs = Object.keys(contents);
    const { select, reason } = await processAiResult(category, contents);

    if (select === undefined || reason === undefined) {
      failureCount++;
      console.log("Failure:", failureCount);
    } else {
      try {
        await incrementCounts(contentIDs, "evaluated");
        contentIDsObj.push(contentIDs);
        await incrementCounts(Object.keys(reason), "selected");
        await insertReasons(reason);
        successCount++;
        console.log("Success:", successCount);
      } catch (error) {
        failureCount++;
        console.log("Failure:", failureCount);
      }
    }
  }
  console.log("contentIDsObj:", contentIDsObj);
  console.log("contentIDsObj.length:", contentIDsObj.length);
  const sortedContentIDsObj = contentIDsObj.sort((a, b) => a - b);
  console.log("sortedContentIDsObj:", sortedContentIDsObj);
}

main();
