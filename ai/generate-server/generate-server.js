import dotenv from 'dotenv';
import OpenAI from 'openai';

dotenv.config({ path: '.env' });

const apiKey = process.env.OPENAI_SECRET_KEY;
const organization = process.env.OPENAI_ORGANIZATION;

// console.log(apiKey, organization);

const openai = new OpenAI({ apiKey, organization });

export const generateGptData = async (category, count = 20) => {
  const [main, sub, minor] = category;
  const completion = await openai.chat.completions.create({
    messages: [
      {
        role: 'system',
        content: `
                - 사용자가 선택한 3가지 카테고리를 기반으로 체크리스트 항목을 20개 생성합니다. 
                - 사용자는 /를 구분자로 3개의 대,중,소 카테고리를 입력합니다.
                - 입력 예시는 다음과 같습니다. 대/중/소
                - 어떤 항목들을 생성해야 사용자에게 도움이 될지 생각해보세요. 그리고 그 생각이 끝난 후 최상의 결과들을 생성해보세요.
                - 항목의 개수는 ${count}개로 제한합니다.
                - 각 항목의 어미는 ~하기, ~기로 끝나야합니다.
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
                `,
      },
      { role: 'user', content: `${main}/${sub}/${minor}` },
    ],
    // model: 'gpt-3.5-turbo-1106',
    model: 'gpt-4-1106-preview',
    response_format: { type: 'json_object' },
  });
  const response = completion.choices[0];
  const checklistItems = JSON.parse(
    response.message.content.replace(/\\n/g, ''),
  );
  console.log(checklistItems);
  return checklistItems;
};
