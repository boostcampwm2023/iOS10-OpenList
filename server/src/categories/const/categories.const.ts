export const CATEGORIES = {
  mainCategory: [
    {
      id: 1,
      name: '준비물',
      subcategories: [
        {
          id: 101,
          name: '국내여행',
          minorCategories: [
            { id: 10101, name: '부산' },
            { id: 10102, name: '제주' },
            { id: 10103, name: '경주' },
            { id: 10104, name: '강원도' },
            { id: 10105, name: '전주' },
            { id: 10106, name: '서울' },
            { id: 10107, name: '대구' },
          ],
        },
        {
          id: 102,
          name: '해외여행',
          minorCategories: [
            { id: 10201, name: '라오스' },
            { id: 10202, name: '태국' },
            { id: 10203, name: '일본' },
            { id: 10204, name: '중국' },
            { id: 10205, name: '미국' },
            { id: 10206, name: '캐나다' },
            { id: 10207, name: '영국' },
            { id: 10208, name: '프랑스' },
            { id: 10209, name: '스페인' },
          ],
        },
      ],
    },
    {
      id: 2,
      name: '장소',
      subcategories: [
        {
          id: 201,
          name: '연인 데이트',
          minorCategories: [
            { id: 20101, name: '영화관' },
            { id: 20102, name: '공원' },
            { id: 20103, name: '미술관' },
            { id: 20104, name: '카페' },
            { id: 20105, name: '바다' },
            { id: 20106, name: '당일치기' },
            { id: 20107, name: '캠핑' },
            { id: 20108, name: '글램핑' },
            { id: 20109, name: '호텔' },
          ],
        },
        {
          id: 202,
          name: '가족 나들이',
          minorCategories: [
            { id: 20201, name: '동물원' },
            { id: 20202, name: '테마파크' },
            { id: 20203, name: '해변' },
            { id: 20204, name: '산' },
            { id: 20205, name: '박물관' },
            { id: 20206, name: '수족관' },
            { id: 20207, name: '놀이동산' },
          ],
        },
      ],
    },
    {
      id: 3,
      name: '활동',
      subcategories: [
        {
          id: 301,
          name: '자기계발',
          minorCategories: [
            { id: 30101, name: '언어 학습' },
            { id: 30102, name: '프로그래밍' },
            { id: 30103, name: '취미 개발' },
          ],
        },
        {
          id: 302,
          name: '레저 스포츠',
          minorCategories: [
            { id: 30201, name: '등산' },
            { id: 30202, name: '서핑' },
            { id: 30203, name: '스노우보딩' },
          ],
        },
      ],
    },
    {
      id: 4,
      name: '식단',
      subcategories: [
        {
          id: 401,
          name: '다이어트',
          minorCategories: [
            { id: 40101, name: '케토' },
            { id: 40102, name: '저탄수화물' },
            { id: 40103, name: '지중해식' },
          ],
        },
        {
          id: 402,
          name: '건강식',
          minorCategories: [
            { id: 40201, name: '채식' },
            { id: 40202, name: '유기농' },
            { id: 40203, name: '글루텐 프리' },
          ],
        },
      ],
    },
    {
      id: 5,
      name: '기술 습득',
      subcategories: [
        {
          id: 501,
          name: '컴퓨터',
          minorCategories: [
            { id: 50101, name: '운영체제' },
            { id: 50102, name: '데이터베이스 관리' },
            { id: 50103, name: '네트워크' },
            { id: 50104, name: '웹 개발' },
            { id: 50105, name: '앱 개발' },
            { id: 50106, name: '게임 개발' },
            { id: 50107, name: '머신러닝' },
            { id: 50108, name: '인공지능' },
            { id: 50109, name: '블록체인' },
            { id: 50110, name: '빅데이터' },
            { id: 50111, name: '사이버 보안' },
            { id: 50112, name: 'C언어' },
            { id: 50113, name: 'C++' },
            { id: 50114, name: 'C#' },
          ],
        },
        {
          id: 502,
          name: '기타 기술',
          minorCategories: [
            { id: 50201, name: '그래픽 디자인' },
            { id: 50202, name: '사진술' },
            { id: 50203, name: '글쓰기' },
            { id: 50204, name: '영상 편집' },
            { id: 50205, name: '음악 제작' },
            { id: 50206, name: '음악 연주' },
          ],
        },
      ],
    },
    {
      id: 6,
      name: '건강 관리',
      subcategories: [
        {
          id: 601,
          name: '정신 건강',
          minorCategories: [
            { id: 60101, name: '명상' },
            { id: 60102, name: '스트레스 관리' },
            { id: 60103, name: '수면 개선' },
          ],
        },
        {
          id: 602,
          name: '신체 건강',
          minorCategories: [
            { id: 60201, name: '운동 루틴' },
            { id: 60202, name: '영양 보충' },
            { id: 60203, name: '건강 검진' },
            { id: 60204, name: '피부 관리' },
            { id: 60205, name: '머리 관리' },
          ],
        },
      ],
    },
    {
      id: 7,
      name: '취미',
      subcategories: [
        {
          id: 701,
          name: '음악',
          minorCategories: [
            { id: 70101, name: '기타' },
            { id: 70102, name: '피아노' },
            { id: 70103, name: '드럼' },
            { id: 70104, name: '베이스' },
            { id: 70105, name: '보컬' },
            { id: 70106, name: '작곡' },
            { id: 70107, name: '음악 이론' },
          ],
        },
        {
          id: 702,
          name: '미술',
          minorCategories: [
            { id: 70201, name: '드로잉' },
            { id: 70202, name: '수채화' },
            { id: 70203, name: '아크릴화' },
            { id: 70204, name: '유화' },
            { id: 70205, name: '파스텔' },
            { id: 70206, name: '캘리그라피' },
            { id: 70207, name: '조소' },
            { id: 70208, name: '판화' },
            { id: 70209, name: '캐리커쳐' },
          ],
        },
        {
          id: 703,
          name: '공예',
          minorCategories: [
            { id: 70301, name: '가죽' },
            { id: 70302, name: '목공' },
            { id: 70303, name: '도자기' },
            { id: 70304, name: '비즈' },
            { id: 70305, name: '플라워' },
            { id: 70306, name: '캔들' },
            { id: 70307, name: '향수' },
            { id: 70308, name: '비누' },
          ],
        },
      ],
    },
  ],
};
