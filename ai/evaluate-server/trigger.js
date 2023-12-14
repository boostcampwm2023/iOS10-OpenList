const RedisPub = require("./RedisPub");

// ai_generate 메시지를 보내는 테스트 코드
const publisher = new RedisPub();
publisher
  .send(
    "ai_generate",
    JSON.stringify({ message: "processAiEvaluate", body: 100 })
  )
  .then(() => {
    process.exit(0);
  });
