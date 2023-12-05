const redis = require("redis");

const publisher = redis.createClient({
  host: "localhost",
  port: 6379,
});

async function init() {
  try {
    await publisher.connect();
    console.log("Redis publisher connected");

    // 메시지 발행
    await publisher.publish("channel", "processAiResult");

    // 발행 후 연결 닫기
    await publisher.quit();
    console.log("Message published and connection closed");
  } catch (err) {
    console.error("An error occurred:", err);
  }
}

init();
