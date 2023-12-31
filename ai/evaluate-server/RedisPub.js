const redis = require("redis");
require("dotenv").config();

// RedisPub 클래스
class RedisPub {
  constructor() {
    this.init();
  }

  async init() {
    try {
      this.publisher = redis.createClient({
        url: process.env.REDIS_URL,
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
