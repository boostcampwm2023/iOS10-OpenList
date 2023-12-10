const RedisPub = require("./RedisPub");

const publisher = new RedisPub();
publisher
  .send(
    "ai_generate",
    JSON.stringify({ message: "processAiEvaluate", body: 100 })
  )
  .then(() => {
    process.exit(0);
  });
