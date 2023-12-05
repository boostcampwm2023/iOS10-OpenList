const redis = require("redis");

class RedisPub {
  constructor() {
    this.init();
  }

  async init() {
    try {
      this.publisher = redis.createClient({
        host: "localhost",
        port: 6379,
      });
      await this.publisher.connect();
      console.log("Redis publisher connected");
    } catch (err) {
      console.error("An error occurred:", err);
    }
  }
  async send(channel, message) {
    await this.publisher.publish(channel, message);
  }
  async close() {
    await this.publisher.quit();
    console.log("connection closed");
  }
}

module.exports = RedisPub;
