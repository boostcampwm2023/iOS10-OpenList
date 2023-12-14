import { HttpService } from '@nestjs/axios';
import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';
import * as process from 'process';
import { CreateChecklistItemsDto } from './dto/create-checklist-items.dto';
import { AI_OPTIONS } from './const/ai-options.const';
import { SYSTEM_ROLE } from './const/system-role.const';
import { CLOVA_API_URL } from './const/request-option.const';

@Injectable()
export class ChecklistAiService {
  constructor(private httpService: HttpService) {}

  // HTTP 요청을 보내는 별도의 메서드
  private async sendRequestToClova(url: string, headers: any, data: any) {
    return await firstValueFrom(this.httpService.post(url, data, { headers }));
  }

  // 응답 데이터에서 필요한 정보를 추출하는 별도의 메서드
  private extractResultData(responseData: any) {
    // 'result.message.content' 에 직접 접근하여 반환.
    // 'result' 또는 'message' 가 없는 경우 null 을 반환.
    return responseData?.result?.message?.content ?? null;
  }

  private getUserRoleWithDto(dto: CreateChecklistItemsDto) {
    return {
      role: 'user',
      content: `대카테고리: ${dto.mainCategory}, 중카테고리: ${dto.minorCategory}, 소카테고리: ${dto.subCategory}`,
    };
  }

  private generateRequestData(dto: CreateChecklistItemsDto) {
    return {
      messages: [SYSTEM_ROLE, this.getUserRoleWithDto(dto)],
      ...AI_OPTIONS,
    };
  }

  private generateRequestHeaders() {
    const CLOVASTUDIO_API_KEY = process.env.X_NCP_CLOVASTUDIO_API_KEY;
    const APIGW_API_KEY = process.env.X_NCP_APIGW_API_KEY;
    const REQUEST_ID = process.env.X_NCP_CLOVASTUDIO_REQUEST_ID;
    return {
      'X-NCP-CLOVASTUDIO-API-KEY': CLOVASTUDIO_API_KEY,
      'X-NCP-APIGW-API-KEY': APIGW_API_KEY,
      'X-NCP-CLOVASTUDIO-REQUEST-ID': REQUEST_ID,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    };
  }

  async generateChecklistItemWithAi(dto: CreateChecklistItemsDto) {
    const url = CLOVA_API_URL;
    const data = this.generateRequestData(dto);
    const headers = this.generateRequestHeaders();

    const response = await this.sendRequestToClova(url, headers, data);
    if (response.status !== 200) {
      throw new ServiceUnavailableException(
        'Chat Completion 서비스 처리 중 오류 발생',
      );
    }

    return this.extractResultData(response.data);
  }
}
