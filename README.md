![image](https://github.com/boostcampwm2023/iOS10-OpenList/assets/53855302/314335b7-9f27-42ff-8eda-2078135970ff)


<div align="center"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fboostcampwm2023/iOS10-OpenList&count_bg=%237B68DC&title_bg=%23464775&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/>
    <img src="https://img.shields.io/github/stars/boostcampwm2023/iOS10-OpenList.svg?style=flat&label=star">
<img src="https://github.com/boostcampwm2023/iOS10-OpenList/actions/workflows/main.yml/badge.svg"></div>
<p align="center">
    <code>2023.10.17 ~ </code>
</p>


# Content
- [주요기능](#주요기능)
- [기술적 도전](#기술적-도전)
- [기술 스택](#기술-스택)
- [아키텍처](#아키텍처)
- [문서](#프로젝트-문서)
- [팀 소개](#TEAM)
- [위키](https://github.com/boostcampwm2023/iOS10-OpenList/wiki)

<br>

# 주요기능
![image](https://hackmd.io/_uploads/HJu_NVS8p.png)
## AI
> 체크리스트 작성이 어려운 사람들을 위해 AI 추천기능을 구현하였습니다.
>
> GPT-4를 이용한 체크리스트 캐싱 시스템, CLOVA Studio를 이용한 평가 시스템을 도입하여 빠르고 정확한 정보를 제공합니다.

<table>
  <tr>
    <th style="width: 33%;">체크리스트 작성을 위해 카테고리를 선택해주세요</th>
    <th style="width: 33%;">선택된 카테고리로 AI가 체크리스트를 추천해줘요</th>
    <th style="width: 33%;">AI가 추천한 목록들로 개인 체크리스트를 만들어요</th>
  </tr>
  <tr>
    <td><img src="https://hackmd.io/_uploads/Sk9dT6SLp.gif" style="width: 100%;"/></td>
    <td><img src="https://hackmd.io/_uploads/ryYtapSUT.gif" style="width: 100%;"/></td>
    <td><img src="https://hackmd.io/_uploads/B1QxCaHIp.gif" style="width: 100%;"/></td>
  </tr>
</table>

## 동시편집!
> 여러명과 동시에 체크리스트를 작성하기 위해 동시편집 기능을 구현하였습니다.
> 
> 동시편집은 CRDT 알고리즘 중에 RGATreeSplit 방식을 채택하였습니다.
<table>
  <tr>
    <th style="width: 33%;">개인 체크리스트를 함께 작성하도록 변경할 수 있어요</th>
    <th style="width: 33%;">친구를 초대하여 체크리스트를 같이 작성할 수 있어요</th>
    <th style="width: 33%;">동시편집시 현재 편집중인 친구의 위치를 알 수 있어요</th>
  </tr>
  <tr>
    <td><img src="https://hackmd.io/_uploads/B1UOiaH8T.gif" style="width: 100%;"/></td>
    <td><img src="https://hackmd.io/_uploads/B1MZ3pBU6.gif" style="width: 100%;"/></td>
    <td><img src="https://hackmd.io/_uploads/SkYjqTrI6.gif" style="width: 100%;"/></td>
  </tr>
</table>

- [[동시편집] CRDT vs OT](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-CRDT-vs-OT)
- [[동시편집] 왜 RGATreeSplit 방식을 채택하였나?](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-%EC%99%9C-RGASplitTree-%EB%B0%A9%EC%8B%9D%EC%9D%84-%EC%B1%84%ED%83%9D%ED%95%98%EC%98%80%EC%9D%84%EA%B9%8C%3F)
- [[동시편집] ID 부여 방식](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-CRDT-ID-%EB%B6%80%EC%97%AC%EB%B0%A9%EC%8B%9D)
- [[동시편집] Tree 방식에서 밸런싱](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-Tree-%EB%B0%A9%EC%8B%9D%EC%97%90%EC%84%9C-%EB%B0%B8%EB%9F%B0%EC%8B%B1)
- [[동시편집] 자소분리 문제 해결과정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-%EC%9E%90%EC%86%8C%EB%B6%84%EB%A6%AC-%ED%95%B4%EA%B2%B0%EA%B3%BC%EC%A0%95)

# [기술적 도전](https://msmspark.notion.site/OPENLIST-a14eede6efb643698f166a0512f4206d?pvs=4)
## 📡 [Redis Pub/Sub과 서버 다중화]()
- 🔗 **서버 다중화**: Redis의 Pub/Sub 모델을 활용하여 서버 다중화를 구현하고, 효율적인 트래픽 분산 및 높은 확장성을 실현했습니다.

- 🔄 **실시간 데이터 스트리밍**: 앱에서는 CRDT를 활용하여 실시간으로 체크리스트를 업데이트하고, 서버는 Redis의 list 자료구조를 이용해 데이터 어레이를 모두 유지하여 사용자의 연결의 끊어져도, 문서에 대한 실시간 최신 상태를 유지합니다.


## 🌐 [Pipe & Filter 아키텍처와 인공지능 데이터 캐싱](https://msmspark.notion.site/Pipe-Filter-fd5f1bbd49934b978f820e9b4ff8d450)
- ⚡ **응답 시간 최적화**: DB에서 카테고리별로 캐싱된 데이터를 활용하여 Clova Studio API 응답 시간을 단축했습니다.

- 🛠 **캐싱 파이프라인**: Pipe & Filter 아키텍처를 적용하여 순차적 데이터 처리와 Redis Pub/Sub을 통한 효율적인 데이터 관리를 구현했습니다.

![이미지](https://github.com/boostcampwm2023/iOS10-OpenList/assets/42074365/ee8fb324-c826-47de-b0cc-e0f712cb4380)


## 💻 [관리자 웹 페이지를 통한 시스템 모니터링]()
- 📊 **실시간 모니터링**: 프로덕션 환경에서 서버 상태를 모니터링하고 장애를 신속하게 관리할 수 있는 관리자 페이지를 구축했습니다.

- 📈 **데이터 관리 및 로깅**: Redis를 통해 시스템 로그를 관리하고, 캐싱 데이터 생성 및 평가 파이프라인을 트리거할 수 있는 기능을 통합했습니다.

![image](https://hackmd.io/_uploads/ryDjsaB8T.png)



# 기술 스택
<details open>
<summary><h3>iOS</h3></summary>
<div markdown="3">

![Xcode](https://img.shields.io/badge/Xcode-15.0.1-blue?style=flat-square&logo=xcode) ![macOS](https://img.shields.io/badge/macOS-Sonoma(14.0)-lightgrey?style=flat-square&logo=apple)

![Minimum Target](https://img.shields.io/badge/Minimum%20Target-16.0-blue?style=flat-square&logo=apple)
![UI Framework](https://img.shields.io/badge/UI%20Framework-UIKit-lightblue?style=flat-square&logo=apple)
![Async Framework](https://img.shields.io/badge/Async%20Framework-Combine-yellow?style=flat-square&logo=apple)
![Architecture](https://img.shields.io/badge/Architecture-Butterfly%20Architecture-orange?style=flat-square)

![Others](https://img.shields.io/badge/Others-Core%20Data-green?style=flat-square&logo=apple)
![Open Source](https://img.shields.io/badge/Open%20Source-SwiftLint-red?style=flat-square&logo=swift)


</div>
</details>


<details open>
<summary><h3>💻 서버</h3></summary>
<div markdown="1">

![NestJS](https://img.shields.io/badge/NestJS-v.10.2.0-brightgreen?style=flat-square&logo=nestjs)
![TypeScript](https://img.shields.io/badge/TypeScript-v.5.1.3-blue?style=flat-square&logo=typescript)

![PostgreSQL](https://img.shields.io/badge/Postgresql-v.15-blue?style=flat-square&logo=postgresql)
![TypeORM](https://img.shields.io/badge/TypeORM-v.10-orange?style=flat-square&logo=typeorm)
![Redis](https://img.shields.io/badge/Redis-v.7.2-red?style=flat-square&logo=redis)

![CLOVA Studio](https://img.shields.io/badge/CLOVA%20Studio-API-yellow?style=flat-square&logo=naver) ![GPT-4](https://img.shields.io/badge/GPT--4-API-purple?style=flat-square&logo=openai)

![Docker](https://img.shields.io/badge/Docker-Tool-blue?style=flat-square&logo=docker) ![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI/CD-blueviolet?style=flat-square&logo=github-actions) ![Nginx](https://img.shields.io/badge/Nginx-Server-lightgrey?style=flat-square&logo=nginx) 
![Ncloud](https://img.shields.io/badge/Ncloud-Service-yellow?style=flat-square&logo=naver)


</div>
</details>

</br>
</br>

# 아키텍처

### iOS 아키텍처
<img width="1000" alt="IOS 아키텍처-버터플라이아키텍처" src="https://hackmd.io/_uploads/Bkp5HTr8a.png"/>

### 서버 아키텍처
<img width="1000" alt="서버 아키텍쳐" src="https://github.com/boostcampwm2023/iOS10-OpenList/assets/51476641/e8102aae-f691-4061-bb68-ebe01109660f">


# 프로젝트 문서

## iOS
### 기술 문서
|번호|제목|키워드|
|:---|:---|:---|
|1|[CRDT vs OT](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-CRDT-vs-OT)|**`CRDT`**|
|2|[왜 RGATreeSplit 방식을 채택하였나?](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-%EC%99%9C-RGASplitTree-%EB%B0%A9%EC%8B%9D%EC%9D%84-%EC%B1%84%ED%83%9D%ED%95%98%EC%98%80%EC%9D%84%EA%B9%8C%3F)|**`CRDT`**|
|3|[ID 부여 방식](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-CRDT-ID-%EB%B6%80%EC%97%AC%EB%B0%A9%EC%8B%9D)|**`CRDT`**|
|4|[Tree 방식에서 밸런싱](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-Tree-%EB%B0%A9%EC%8B%9D%EC%97%90%EC%84%9C-%EB%B0%B8%EB%9F%B0%EC%8B%B1)|**`CRDT`**|
|5|[자소분리 문제 해결과정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EB%8F%99%EC%8B%9C%ED%8E%B8%EC%A7%91%5D-%EC%9E%90%EC%86%8C%EB%B6%84%EB%A6%AC-%ED%95%B4%EA%B2%B0%EA%B3%BC%EC%A0%95)|**`CRDT`**|
|6|[딥링크로 체크리스트 초대하기](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/딥링크로-체크리스트-초대하기)|**`딥링크`**|
|7|[프레임워크 vs 라이브러리](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BFramework-&-Library%5D-%EB%AC%B4%EC%97%87%EC%9D%B4-%EB%A7%9E%EC%9D%84%EA%B9%8C)|**`모듈`**|
|8|[소켓통신: Any와의 싸움](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5B%EC%86%8C%EC%BC%93%ED%86%B5%EC%8B%A0%5D-Any-Type%EA%B3%BC%EC%9D%98-%EC%8B%B8%EC%9B%80)|**`소켓`**|

### 의사결정 기록
|제목|키워드|
|:---|:---|
[[ADR] 아키텍처 의사 결정 기록: iOS 애플리케이션 아키텍처 채택하기](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-iOS-애플리케이션-아키텍처-채택하기)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: SwiftLint 채택](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:--SwiftLint-채택)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: UI 영역에서 Combine 사용 결정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-UI-영역에서-Combine-사용-결정)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: Presentation영역의 ViewModel에서 Input Output 패턴 도입 결정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-Presentation영역의-ViewModel에서-Input-Output-패턴-도입-결정)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: 코디네이터 패턴 도입 결정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-코디네이터-패턴-도입-결정)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: 로컬 스토리지로 코어 데이터 사용 결정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-로컬-스토리지로-코어-데이터-사용-결정)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: Custom Network Foundation 라이브러리 구현 및 모듈화 결정](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-Custom-Network-Foundation-라이브러리-구현-및-모듈화-결정)|**`ADR`**|
|[[ADR] 아키텍처 의사 결정 기록: 웹 소켓을 뷰 컨트롤러에서 연결하도록 변경](https://github.com/boostcampwm2023/iOS10-OpenList/wiki/%5BADR%5D-아키텍처-의사-결정-기록:-웹-소켓을-뷰-컨트롤러에서-연결하도록-변경)|**`ADR`**|

</div>
</details>

# TEAM
|S006|S008|S021|J050|J080|
|:---:|:---:|:---:|:---:|:---:|
|<img src="https://github.com/SeongHunTed.png" width="120">|<img src="https://github.com/klmyoungyun.png" width="120"/>|<img src="https://github.com/wi-seong-cheol.png" width="120"/>|<img src="https://github.com/pminsung12.png" width="120"/>|<img src="https://github.com/YangDongsuk.png" width="120"/>|
|[김성훈](https://github.com/SeongHunTed)|[김영균](https://github.com/klmyoungyun)|[위성철](https://github.com/wi-seong-cheol)|[박민성](https://github.com/pminsung12)|[양동석](https://github.com/YangDongsuk)|
|iOS|iOS|iOS|Backend|Backend|
