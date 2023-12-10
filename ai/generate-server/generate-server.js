import dotenv from 'dotenv';
import OpenAI from 'openai';

dotenv.config({ path: '.env' });

const apiKey = process.env.OPENAI_SECRET_KEY;
const organization = process.env.OPENAI_ORGANIZATION;

// console.log(apiKey, organization);

/**
 * 응답이 유효한지 확인합니다.
 * @param response
 * @param count
 */
const checkIfValidResponse = (response, count) => {
  const responseLength = Object.keys(response).length;
  if (responseLength !== count) {
    throw new Error(`Invalid response length: ${responseLength}`);
  }

  // 객체의 각 값의 길이가 30자 이하인지 확인
  if (!Object.values(response).every((item) => item.length <= 30)) {
    throw new Error(
      `Invalid response item length: ${JSON.stringify(response)}`,
    );
  }
};

/**
 * 카테고리를 받아서 gpt-4로 데이터 생성 후 postgres에 저장
 * @param category
 * @param count
 * @returns {Promise<any>}
 */
export const generateGptData = async (category, count = 10) => {
  const openai = new OpenAI({ apiKey, organization });
  const [main, sub, minor] = category;
  console.log('main,sub,minor:', category);
  const content = `
                - 사용자가 선택한 3가지 카테고리를 기반으로 체크리스트 항목을 ${count}개 생성합니다. 
                - 사용자는 , 구분자로 3개의 대,중,소 카테고리를 배열 형태로 입력합니다.
                - 입력 예시는 다음과 같습니다. ["식단", "건강식", "무첨가식품"]
                - 항목의 개수는 ${count}개로 제한합니다.
                - 각 항목의 어미는 ~하기, ~기 또는 명사로 끝나야합니다.
                - 각 항목의 글자 수는 30자 이하로 생성합니다.
                - 응답 형식인 json 형식은 다음과 같습니다.
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
                `;
  console.log('content:', content);

  // 에러가 나면 retry
  let retryCount = 1;
  while (retryCount--) {
    try {
      const completion = await openai.chat.completions.create({
        messages: [
          {
            role: 'system',
            content,
          },
          { role: 'user', content: `${category}}` },
        ],
        // model: 'gpt-3.5-turbo-1106',
        // model: 'gpt-4',
        model: 'gpt-4-1106-preview',
        // temperature: 1.5, // randomness
        response_format: { type: 'json_object' },
      });
      console.log('gpt start');
      // console.log('completion:', completion);
      const response = completion.choices[0];
      console.log('response: ', response);
      const checklistItems = JSON.parse(
        response.message.content.replace(/\\n/g, ''),
      );
      console.log(checklistItems);
      checkIfValidResponse(checklistItems, count);
      return checklistItems;
    } catch (error) {
      console.error('Error during AI generation:', error);
      retryCount++;
    }
  }
};

// generateGptData(['관광명소', '국내여행', '경주']);
