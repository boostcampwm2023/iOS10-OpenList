require("dotenv").config();
const axios = require("axios");

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
  
  출력 결과
  
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
  try {
    const headers = {
      "X-NCP-CLOVASTUDIO-API-KEY": process.env.X_NCP_CLOVASTUDIO_API_KEY,
      "X-NCP-APIGW-API-KEY": process.env.X_NCP_APIGW_API_KEY,
      "X-NCP-CLOVASTUDIO-REQUEST-ID": process.env.X_NCP_CLOVASTUDIO_REQUEST_ID,
      "Content-Type": "application/json",
      Accept: "application/json",
    };

    const response = await axios.post(CLOVA_API_URL, data, { headers });
    return response.data;
  } catch (error) {
    console.error("Error during API request:", error.message);
    throw new Error("Service unavailable");
  }
}

function getUserRoleWithDto(dto) {
  return {
    role: "user",
    content: `{
        "mainCategory":"해외 여행",
        "subCategory":"라오스",
        "minorCategory":"관광명소"
    }
    {
    "1": "라오스 문화에 대해 알아보기",
    "2": "불교 사원 방문하기",
    "3": "자연 경관 감상하기",
    "4": "동굴 탐험하기",
    "5": "액티비티 체험하기",
    "6": "현지 음식 즐기기",
    "7": "전통 공예품 구매하기",
    "8": "교통 수단 이용 시 주의사항 숙지하기",
    "9": "안전에 유의하며 여행하기",
    "10": "여행 준비물 꼼꼼히 챙기기"
    }`,
  };
}

async function evaluateChecklistItem(dto) {
  const requestData = {
    messages: [SYSTEM_ROLE, getUserRoleWithDto(dto)],
    ...AI_OPTIONS,
  };

  const result = await sendRequestToClova(requestData);
  return result;
}

// DTO (Data Transfer Object) 예시
const dtoExample = {
  mainCategory: "여행",
  subCategory: "유럽",
  minorCategory: "관광명소",
};

// generateChecklistItemWithAi(dtoExample)
//   .then((result) => console.log("Generated checklist:", result))
//   .catch((error) => console.error("Error:", error));

async function aiResultParser(result) {
  const content = result?.result?.message?.content;
  const parsedContent = JSON.parse(content);
  const { select, reason } = parsedContent;

  return { select, reason };
}

async function checkValidResult(select, reason) {
  if (select.length !== 3) {
    throw new Error("select 항목이 3개가 아닙니다.");
  }
  if (Object.keys(reason).length !== 3) {
    throw new Error("reason 항목이 3개가 아닙니다.");
  }
  if (select.some((item) => !reason[item])) {
    throw new Error("select 항목에 reason 항목이 없습니다.");
  }
  if (select.some((item) => isNaN(item))) {
    throw new Error("select 항목이 숫자가 아닙니다.");
  }
}

async function processAiResult(retryCount = 0) {
  try {
    const result = await evaluateChecklistItem(dtoExample);
    const { select, reason } = await aiResultParser(result);
    await checkValidResult(select, reason);
    console.log("select:", select);
    console.log("reason:", reason);
  } catch (error) {
    if (retryCount < 3) {
      console.log("retryCount:", retryCount + 1);
      processAiResult(retryCount + 1);
    } else {
      console.error("Error:", error);
    }
  }
}

// processAiResult();

module.exports = {
  processAiResult,
};
