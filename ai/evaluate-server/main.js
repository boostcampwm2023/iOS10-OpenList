const {
  getAllCategories,
  getAllChecklistItems,
  getMinMaxEvaluatesByCategory,
  getChecklistItemsByCategoryAndEvaluateCount,
  getChecklistItemsByEvaluateCount,
  pool,
} = require("./postgres.js");

const { processAiResult } = require("./evaluate-api.js");
async function main() {
  const checklistItemsByEvaluateCount = await getChecklistItemsByEvaluateCount(
    2
  );
  const result = transformAndChunkItems(checklistItemsByEvaluateCount);
  console.log("expected count: ", result.length);
  console.log("result:", result);
  //   result.forEach(async (item) => {
  //     const { category, contents } = item;
  //     await processAiResult(category, contents);
  //   });
  processResultsSequentially(result).then(() => {
    console.log("모든 처리가 완료되었습니다.");
  });
  pool.end();
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
  for (const item of result) {
    const { category, contents } = item;
    const { select, reason } = await processAiResult(category, contents);
    if (select === undefined || reason === undefined) {
      failureCount++;
      console.log("failureCount:", failureCount);
    } else {
      successCount++;
      console.log("select:", select);
      console.log("reason:", reason);
    }
  }
}

// 사용 예시

main();
