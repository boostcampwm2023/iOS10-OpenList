const os = require('os');
const redis = require('redis');

// 환경 변수
const REDIS_URL = 'redis://localhost:6379';
const SERVER_NAME = 'nest2';

// Redis 클라이언트 설정
const client = redis.createClient({
  url: REDIS_URL,
});

client.on('error', (err) => {
  console.log('Redis Client Error', err);
});

client.connect();

let lastCpuInfo = getCpuInfo();

// CPU 정보 수집 함수
function getCpuInfo() {
  const cpus = os.cpus();
  let totalIdle = 0,
    totalTick = 0;

  for (let cpu of cpus) {
    for (const type in cpu.times) {
      totalTick += cpu.times[type];
    }
    totalIdle += cpu.times.idle;
  }

  return { totalIdle, totalTick };
}

// CPU 사용률 계산 함수
function getCpuUsage() {
  const currentCpuInfo = getCpuInfo();
  const idleDifference = currentCpuInfo.totalIdle - lastCpuInfo.totalIdle;
  const totalDifference = currentCpuInfo.totalTick - lastCpuInfo.totalTick;
  const usage = (1 - idleDifference / totalDifference) * 100;
  lastCpuInfo = currentCpuInfo;

  return usage.toFixed(2);
}

// 시스템 상태를 수집하고 Redis에 publish하는 함수
function publishSystemStats() {
  const stats = {
    freeMemory: os.freemem(),
    totalMemory: os.totalmem(),
    cpuUsage: getCpuUsage(),
    uptime: os.uptime(),
  };

  // Redis에 publish
  client.publish('system-stats-' + SERVER_NAME, JSON.stringify(stats));

  console.log('Published system stats:', stats);
}

// 5초마다 시스템 상태 publish
setInterval(publishSystemStats, 2000);
