const os = require('os');
const redis = require('redis');
const { exec } = require('child_process');
dotenv = require('dotenv');

// Redis 클라이언트 설정
const client = redis.createClient({
  url: process.env.REDIS_URL,
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

// 네트워크 트래픽 정보 파싱 및 총 사용량 계산 함수
function parseNetworkTraffic(data) {
  const lines = data.split('\n');
  let totalIpkts = 0,
    totalOpkts = 0;

  for (const line of lines) {
    const parts = line.trim().split(/\s+/);
    if (parts.length > 4 && parts[0] !== 'Name') {
      const ipkts = parseInt(parts[4], 10);
      const opkts = parseInt(parts[6], 10);
      totalIpkts += ipkts;
      totalOpkts += opkts;
    }
  }

  return { totalIpkts, totalOpkts };
}

// 네트워크 트래픽 정보 수집 함수
function getNetworkTraffic(callback) {
  exec('netstat -i', (err, stdout, stderr) => {
    if (err) {
      console.error('Error executing netstat:', err);
      return;
    }
    callback(parseNetworkTraffic(stdout));
  });
}

// 시스템 상태를 수집하고 Redis에 publish하는 함수
function publishSystemStats() {
  getNetworkTraffic((networkTraffic) => {
    const stats = {
      freeMemory: os.freemem(),
      totalMemory: os.totalmem(),
      cpuUsage: getCpuUsage(),
      uptime: os.uptime(),
      networkTraffic: networkTraffic, // 총 네트워크 사용량 표시
    };

    // Redis에 publish
    client.publish('system-stats', JSON.stringify(stats));

    console.log('Published system stats:', stats);
  });
}

// 5초마다 시스템 상태 publish
setInterval(publishSystemStats, 2000);
