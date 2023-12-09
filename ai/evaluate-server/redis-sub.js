const redis = require("redis");
const { processAiResult } = require("./evaluate-api");
const { getAllChecklistItems } = require("./postgres");
const RedisPub = require("./RedisPub");

const subscriber = redis.createClient({
  host: "localhost",
  port: 6379,
});

async function init() {
  const publisher = new RedisPub();
  const redisSub = await subscriber.connect();
  redisSub.subscribe("channel", async function (message) {
    try {
      console.log("message:", message);
      if (message === "processAiResult") {
        console.log("start");
        publisher.send("channel", "processAiResult start");
        await processAiResult();
        console.log("finished");
        publisher.send("channel", "processAiResult finished");
        console.log("get data from postgres");
        // const checklistItems = await getAllChecklistItems();
        // console.log("checklistItems:", checklistItems);
        console.log("end");
      }
    } catch (error) {
      console.error(`Error while processing ${message}: `, error);
    }
  });
}
init();
