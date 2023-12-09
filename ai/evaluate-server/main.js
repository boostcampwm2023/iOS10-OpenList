const {
  getAllCategories,
  getAllChecklistItems,
  getMinMaxEvaluatesByCategory,
  getChecklistItemsByCategoryAndEvaluateCount,
  getChecklistItemsByEvaluateCount,
  pool,
} = require("./postgres.js");
async function main() {
  const checklistItemsByEvaluateCount = await getChecklistItemsByEvaluateCount(
    2
  );
  const result = transformAndChunkItems(checklistItemsByEvaluateCount);
  console.log("result:", result);
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

main();
