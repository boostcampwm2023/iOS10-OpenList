const redis = require("redis");
const { processAiResult } = require("./evaluate-api");

const subscriber = redis.createClient({
  host: "localhost",
  port: 6379,
});

async function init() {
  const redisSub = await subscriber.connect();
  redisSub.subscribe("channel", async function (message) {
    console.log("message:", message);

    if (message === "processAiResult") {
      console.log("start");
      await processAiResult();
      console.log("finished");
    }
  });
}
init();
