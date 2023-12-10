const {
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  pool,
} = require("./postgres.js");
const { PromisePool } = require("@supercharge/promise-pool");
const RedisPub = require("./RedisPub");
const redis = require("redis");

const subscriber = redis.createClient({
  url: process.env.REDIS_URL,
});

const publisher = new RedisPub();

const { processAiResult } = require("./evaluate-api.js");
async function main() {
  const redisSub = await subscriber.connect();
  redisSub.subscribe("ai_generate", async function (data) {
    try {
      const { message, body } = parseJsonData(data);
      if (message === "processAiEvaluate") {
        publisher.send(
          "ai_evaluate",
          `received: ${message} ${body} processAiEvaluate start`
        );
        const evaluateCountMax = parseInt(body);
        const checklistItemsByEvaluateCount =
          await getChecklistItemsByEvaluateCount(evaluateCountMax);
        const result = transformAndChunkItems(checklistItemsByEvaluateCount);
        const evaluateCycle = result.length;
        publisher.send("ai_evaluate", `expected count: ${evaluateCycle}`);

        await processResultsSequentially(result); // 작업이 완료될 때까지 기다림
        console.log("모든 처리가 완료되었습니다.");
        publisher.send("ai_evaluate", `모든 처리가 완료되었습니다.`);
      }
    } catch (error) {
      console.error("An error occurred:", error);
      publisher.send("ai_evaluate", `An error occurred: ${error}`);
    }
  });
}

function parseJsonData(data) {
  try {
    return JSON.parse(data);
  } catch (error) {
    return { message: "", body: "0" };
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
  const proccessCycle = result.length;

  const { results, errors } = await PromisePool.withConcurrency(10) // 동시에 처리할 작업 수를 10개로 설정
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
          console.log(`Success: ${successCount} / ${proccessCycle}`);
          publisher.send(
            "ai_evaluate",
            `Success: ${successCount} / ${proccessCycle}`
          );
        } catch (error) {
          failureCount++;
          // console.log("Failure:", failureCount);
          // publisher.send("ai_generate", `Failure: ${failureCount}`);
          console.error("An error occurred:", error);
          publisher.send("ai_evaluate_error", `An error occurred: ${error}`);
          console.log(`Failure: ${failureCount} / ${proccessCycle}`);
          publisher.send(
            "ai_evaluate",
            `Failure: ${failureCount} / ${proccessCycle}`
          );
        }
      }
    });

  // 오류 로그
  if (errors.length) {
    console.log("Errors:", errors);
  }
}

main();
