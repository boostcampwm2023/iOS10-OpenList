require("dotenv").config();
const axios = require("axios");
const RedisPub = require("./RedisPub");

const publisher = new RedisPub();

const AI_OPTIONS = {
  topP: 0.8,
  topK: 0,
  maxTokens: 256,
  temperature: 1,
  repeatPenalty: 7.0,
  stopBefore: [],
  includeAiFilters: true,
};

const CLOVA_API_URL =
  "https://clovastudio.stream.ntruss.com/testapp/v1/chat-completions/HCX-002";

const SYSTEM_ROLE = {
  role: "system",
  content: `너는 평가자야
  사용자가 대 중 소 카테고리를 기반으로 추천 체크리스트를 만들었어
  체크리스트에는 10개의 항목이 있어. 이 중에서 카테고리에 잘 어울리는 체크리스트 3개를 선택해서 번호와 이유를 JSON 형식으로 제공해 줘.
  오직 JSON 형식으로만 출력해야 해.
  
  사용자가 입력할 정보
  1. 대 중 소 카테고리 JSON
  {
      "mainCategory": "대",
      "subCategory": "중",
      "minorCategory": "소"
  }
  
  2. 체크리스트 JSON
  {
      "1": "생성된 체크리스트1",
      "2": " 생성된 체크리스트2",
      "3": "생성된 체크리스트3",
      "4": "생성된 체크리스트4",
      "5": "생성된 체크리스트5",
      "6": "생성된 체크리스트6",
      "7": "생성된 체크리스트7",
      "8": "생성된 체크리스트8",
      "9": "생성된 체크리스트9",
      "10": "생성된 체크리스트10"
  }
  
  
  {
      "select": [
          "number1",
          "number2",
          "number3"
      ],
      "reason": {
          "number1": "reason1",
          "number2": "reason2",
          "number3": "reason3"
      }
  }
    `,
};

async function sendRequestToClova(data) {
  const headers = {
    "X-NCP-CLOVASTUDIO-API-KEY": process.env.X_NCP_CLOVASTUDIO_API_KEY,
    "X-NCP-APIGW-API-KEY": process.env.X_NCP_APIGW_API_KEY,
    "X-NCP-CLOVASTUDIO-REQUEST-ID": process.env.X_NCP_CLOVASTUDIO_REQUEST_ID,
    "Content-Type": "application/json",
    Accept: "application/json",
  };

  const response = await axios.post(CLOVA_API_URL, data, { headers });
  return response.data;
}

function getUserRole(categoryDto, checklistDto) {
  return {
    role: "user",
    content: `
    1. 대 중 소 카테고리 JSON
    ${JSON.stringify(categoryDto)}
    2. 체크리스트 JSON
    ${JSON.stringify(checklistDto)}`,
  };
}

async function evaluateChecklistItem(categoryDto, checklistDto) {
  const requestData = {
    messages: [SYSTEM_ROLE, getUserRole(categoryDto, checklistDto)],
    ...AI_OPTIONS,
  };

  const result = await sendRequestToClova(requestData);
  return result;
}

async function aiResultParser(result) {
  const content = result?.result?.message?.content;
  const parsedContent = JSON.parse(content);
  const { select, reason } = parsedContent;

  return { select, reason };
}

async function checkValidResult(select, reason, checklistDto) {
  if (select.length !== 3) {
    throw new Error("select 항목이 3개가 아닙니다.");
  }
  if (Object.keys(reason).length !== 3) {
    throw new Error("reason 항목이 3개가 아닙니다.");
  }
  if (Object.keys(reason).some((item) => isNaN(item))) {
    throw new Error("reason의 키 항목이 숫자가 아닙니다.");
  }
  if (select.some((item) => isNaN(item))) {
    throw new Error("select 항목이 숫자가 아닙니다.");
  }
  const checklistDtoKeys = Object.keys(checklistDto);
  if (!Object.keys(reason).every((key) => checklistDtoKeys.includes(key))) {
    throw new Error("reason의 키에 해당하는 checklistDto의 키가 없습니다.");
  }
}

function delay(time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}

function getRandomDelay(min, max) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

async function processAiResult(categoryDto, checklistDto, maxRetries = 10) {
  let retryCount = 0;
  while (retryCount < maxRetries) {
    try {
      const result = await evaluateChecklistItem(categoryDto, checklistDto);
      const { select, reason } = await aiResultParser(result);
      await checkValidResult(select, reason, checklistDto);
      await publisher.send(
        "ai_evaluate",
        JSON.stringify({ message: "result", body: { select, reason } })
      );
      console.log("select:", select);
      console.log("reason:", reason);
      return { select, reason };
    } catch (error) {
      // 429 에러인 경우, 2초에서 5초 사이의 랜덤한 시간 동안 대기 후 재시도
      if (error?.response?.status === 429) {
        console.error("Too many requests");
        const delayTime = getRandomDelay(2000, 10000); // 2초에서 5초 사이의 랜덤한 시간
        console.log(`Waiting for ${delayTime}ms before retry...`);
        await publisher.send(
          "ai_evaluate_error",
          `Too many requests::Waiting for ${delayTime}ms before retry...`
        );
        await delay(delayTime);
        continue; // 다음 시도로 이동
      }
      console.error("Error:", error.message);
      await publisher.send("ai_evaluate_error", error.message);
      console.log("retryCount:", retryCount + 1);
      await publisher.send(
        "ai_evaluate_error",
        `retryCount: ${retryCount + 1}`
      );
      retryCount++;
    }
  }
  if (retryCount === maxRetries) {
    console.error("모든 재시도 실패");
    await publisher.send("ai_evaluate_error", "모든 재시도 실패");
    return { select: undefined, reason: undefined };
  }
}

// processAiResult();

module.exports = {
  processAiResult,
};
