<img height="75" align="left" alt="OpenListAppIcon" src="https://hackmd.io/_uploads/rkuPMDeNa.png"/> 

# OpenList 
**친구와 함께, AI와 함께 체크리스트 작성을!**

# TEAM
|S006|S008|S021|J050|J080|
|:---:|:---:|:---:|:---:|:---:|
|<img src="https://github.com/SeongHunTed.png" width="120">|<img src="https://github.com/klmyoungyun.png" width="120"/>|<img src="https://github.com/wi-seong-cheol.png" width="120"/>|<img src="https://github.com/pminsung12.png" width="120"/>|<img src="https://github.com/YangDongsuk.png" width="120"/>|
|[김성훈](https://github.com/SeongHunTed)|[김영균](https://github.com/klmyoungyun)|[위성철](https://github.com/wi-seong-cheol)|[박민성](https://github.com/pminsung12)|[양동석](https://github.com/YangDongsuk)|
|iOS|iOS|iOS|WEB|WEB|

# Content
- [주요기능](#주요기능)
- [기술 스택](#기술-스택)
- [규칙](#규칙)
- [위키](https://github.com/boostcampwm2023/iOS10-OpenList/wiki)

# 주요기능
- `CRDT` 기술을 사용하여 사람들과 체크리스트 동시 편집
- `Naver Clova Studio` 를 활용한 AI가 추천한 체크리스트 제공

# 기술 스택
## 클라이언트
**`Xcode 및 MacOS 버전`**
- 15.0.1 / Sonoma(14.0)

**`의존성 관리 도구`**
- Swift Package Manager

**`미니멈 타겟`**
- 16.0

**`UI 프레임워크`**
- UIKit

**`비동기 프레임워크`**
- [Combine](https://developer.apple.com/documentation/combine)

**`아키텍처`**
- [Butterfly Architecture](https://medium.com/@jungkim/%EB%B2%84%ED%84%B0%ED%94%8C%EB%9D%BC%EC%9D%B4-%EC%95%84%ED%82%A4%ED%85%8D%EC%B2%98%EB%A5%BC-%EC%86%8C%EA%B0%9C%ED%95%A9%EB%8B%88%EB%8B%A4-9d4abd71c3c1)
- Router Pattern

**`기타`**
- [Core Data](https://developer.apple.com/documentation/coredata/)
- [Swift.Network](https://developer.apple.com/documentation/network)
- [APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)

**`오픈소스`**
- [SwiftLint](https://github.com/realm/SwiftLint)

## 서버
**`Nest 버전`**
- [NestJS](https://nestjs.com/) v.10.2.0
- [TypeScript](https://www.typescriptlang.org/) v.5.1.3

**`데이터베이스`**
- [Postgresql](https://www.postgresql.org/)
- [TypeORM](https://typeorm.io/)
- [Redis](https://redis.io/)

**`테스트`**
- [Jest](https://jestjs.io/)

**`AI`**
- [CLOVA Studio](https://www.ncloud.com/product/aiService/clovaStudio)

**`DevOps`**
- [Docker](https://www.docker.com/)
- [Ncloud](https://www.docker.com/)
- [Nginx](https://www.nginx.com/)
- [GitHub Actions](https://docs.github.com/ko/actions)

## 협업 도구
- [XD](https://helpx.adobe.com/xd/user-guide.html) - A digital design app for Mac (paid)
- [Notion](https://helpx.adobe.com/xd/user-guide.html) - A digital design app for Mac (paid)
- [Slack](https://helpx.adobe.com/xd/user-guide.html) - A digital design app for Mac (paid)

# 규칙
<details>
<summary>
<b>
<a href="https://github.com/boostcampwm2023/iOS10-OpenList/wiki/그라운드-룰">그라운드 룰</a>
</b>
</summary>
<div markdown="1">
    
## 🐥 오리 규칙
**✅ 오리들 수면 시간을 보장합니다.**
  - 수면 코어 시간: `04:00 ~ 07:00`
  - 최소 6시간을 지킵니다.
```
잠깐! 오리들 수면 시간
  - 성훈님: `04:00 ~ 09:00`
  - 성철님: `01:00 ~ 09:00`
  - 영균님: `12:00 ~ 07:30`
  - 동석님: `07:00 ~ 09:00`, `12:00 ~ 16:00(마스터클래스 없는 날)`
  - 민성님: `03:00 ~ 09:50`
```

**✅ 코어타임을 준수합니다.**
  - 참석하기 어려운 상황이 있다면 팀원에게 미리 알려줍니다.
  - 평일에 열심히하고 주말엔 쉽니다.

**✅ 회의**
 - 50분 회의 10분 휴식을 준수합니다.
 - 끝내는 시간을 정하고 회의를 시작합니다.

**✅ 스크럼 마스터는 서로 돌아가면서합니다.**

</div>
</details>

<details>
<summary>
<b>
<a href="https://github.com/boostcampwm2023/iOS10-OpenList/wiki/브랜치-전략">브랜치 전략</a>
</b>
</summary>
<div markdown="2">

## 🐥 오리의 브랜치 전략
**main branch**
- `main`

**develop branch**
- `ios/develop`
- `backend/develop`

**feature branch**
- `ios/feature/#{issue_number}`
- `backend/feature/#{issue_number}`

**release branch**
> 릴리즈 넘버 규칙 : `major.minor.patch`
- `ios/release/#{release_number}`
- `backend/release/#{release_number}`

</div>
</details>


<details>
<summary>
<b>
<a href="https://github.com/boostcampwm2023/iOS10-OpenList/wiki/커밋-전략">커밋 전략</a>
</b>
</summary>
<div markdown="3">

## 🐥 커밋 전략
```
# <타입>: <제목>
#
# 본문은 위에 작성
# --- COMMIT END ---
#
# <타입> 리스트
#   feat    : 기능 (새로운 기능)
#   fix     : 버그 (버그 수정)
#   refactor: 리팩토링
#   style   : 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
#   docs    : 문서 (문서 추가, 수정, 삭제)
#   test    : 테스트 (테스트 코드 추가, 수정, 삭제: 비즈니스 로직에 변경 없음)
#   chore   : 빌드 업무 수정, 패키지 매니저 수정
#
# ------------------
#
#   타입은 영어로 작성하고 제목과 본문은 한글로 작성한다.
#   제목 끝에 마침표(.) 금지
#   제목과 본문을 한 줄 띄워 분리하기
#   본문은 "어떻게" 보다 "무엇을", "왜"를 설명한다.
#   본문에 여러줄의 메시지를 작성할 땐 "-"로 구분
#
# ------------------
#
# 예시
#   feat: 회원 가입 기능 구현
#   fix: jwt 버그 수정
#   docs: 스프린트 계획 추가
#   style: 코드 인덴트 수정
#   style: 코드 띄어쓰기 수정
#   style: 변수명 변경
#   style: 주석 제거
#   refactor: 회원 가입 로직 리팩토링
#   test: 뷰 모델 테스트 코드 추가
#   chore: 빌드 패키지 수정
```

</div>
</details>
