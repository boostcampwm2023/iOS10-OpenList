const redis = require("redis");

const subscriber = redis.createClient({
  host: "localhost",
  port: 6379,
});

async function init() {
  const redisSub = await subscriber.connect();
  redisSub.subscribe("channel", function (err, message) {
    console.log("message", message);
    if (err) {
      console.log(err);
    }
  });
}
init();
