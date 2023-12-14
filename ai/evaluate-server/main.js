const { PromisePool } = require("@supercharge/promise-pool");
const RedisPub = require("./RedisPub");
const redis = require("redis");
const {
  getChecklistItemsByEvaluateCount,
  incrementCounts,
  insertReasons,
  setFinalScore,
  pool,
} = require("./postgres.js");
const { processAiResult } = require("./evaluate-api.js");

const subscriber = redis.createClient({
  url: process.env.REDIS_URL,
});

const publisher = new RedisPub();

// 메인 함수
// processAiEvaluate 메시지를 받으면 ai_evaluate를 시작하는 함수
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

        await processResultsConcurrency(result); // 작업이 완료될 때까지 기다림
        console.log("모든 평가가 완료되었습니다.");
        publisher.send("ai_evaluate", `모든 평가가 완료되었습니다.`);
        await setFinalScore();
        console.log("final_score가 업데이트되었습니다.");
        publisher.send("ai_evaluate", `final_score가 업데이트되었습니다.`);
      }
    } catch (error) {
      console.error("An error occurred:", error);
      publisher.send("ai_evaluate", `An error occurred: ${error}`);
    }
  });
}

// JSON 데이터를 파싱하는 함수
function parseJsonData(data) {
  try {
    return JSON.parse(data);
  } catch (error) {
    return { message: "", body: "0" };
  }
}

// 카테고리별로 아이템을 묶고, 10개씩 묶어서 반환하는 함수
function transformAndChunkItems(items, chunkSize = 10) {
  const categoryMap = {};
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

// ai evaluate를 동시에 여러개 처리하는 함수
async function processResultsConcurrency(result) {
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
