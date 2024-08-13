# kor_search

PostgreSQL용 한국어 텍스트 검색 확장.

## 설명

`kor_search` 확장은 한국어와 영어 텍스트 간의 검색 기능을 제공하는 PostgreSQL 확장입니다. 번역기, 형태소 분석기 등의 외부 API 의존 없이 개발되었으며, 단어 검색에 최적화되어 있습니다. 문장 대 문장 검색도 어느 정도 가능하지만, 주로 단어 기반의 검색을 위해 설계되었습니다. 이 확장은 PostgreSQL을 설치한 환경(로컬, EC2 등)에서 사용할 수 있으며, 외부 익스텐션 사용이 제한된 환경(RDS)에서 대체로 사용할 수 있는 함수도 제공하고 있습니다.

### 주요 기능

- **LIKE 검색**: 입력된 텍스트가 지정된 검색어와 일치하거나 포함되는지 확인합니다.
- **tsvector 검색**: 텍스트를 tsvector 형식으로 변환하여 유사 단어 검색을 지원합니다.
- **정규식 검색**: 복잡한 검색 조건을 위한 정규식 검색을 제공합니다.
- **유사성 검색**: 단어집을 기반으로 문장 간 유사성을 평가합니다.

### 유연한 맞춤형 검색

`kor_search`는 내부 테이블 데이터를 변경하여 사업군 또는 특정 필드에 맞춘 검색을 제공할 수 있습니다. 예를 들어, 산업의 역군에서는 건설 관련 데이터를 많이 적용하여, 건설 산업에 최적화된 검색을 구현하여 사용 중입니다.

### 성능 고려 사항

단어집의 용량에 따라 대량 데이터를 조회할 때 성능 저하가 발생할 수 있으므로, 성능 분석이 필수적입니다. 또한, 외부 익스텐션 사용이 제한된 RDS 환경에서도 유사한 기능을 제공하는 함수들이 구현되어 있지만, 성능 면에서 본격적인 익스텐션만큼 뛰어나지는 않습니다.

## 설치

### 로컬 PostgreSQL 또는 EC2에서

1. 먼저 PostgreSQL 익스텐션을 빌드하고 설치하려면 다음 명령어를 실행하세요:

    ```sh
    make
    sudo make install
    ```

2. 그런 다음, PostgreSQL 데이터베이스에 접속하여 확장을 활성화합니다:

    ```sh
    psql -U your_username -d your_database
    CREATE EXTENSION kor_search;
    ```

### Amazon RDS에서

1. RDS 인스턴스에 접속합니다. 예를 들어, `psql`을 사용하여 접속할 수 있습니다:

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `kor_search_rds.sql` 파일의 내용을 직접 복사하여 RDS 인스턴스의 SQL 프롬프트에 붙여넣어 실행합니다. 이 파일에는 `kor_search`의 기능을 구현하기 위한 SQL 코드가 포함되어 있습니다.

## 함수

### kor_search_similar

- `kor_search_similar(input_text text, search_text text)`: `input_text`가 `search_text`와 의미적으로 유사한지 판단합니다. 이 함수는 단어집에 등록된 유사어를 기반으로 문장 간의 유사성을 평가합니다.

#### 사용 예시:

1. 문장 간 유사성 검사:

    ```sql
    -- '밥 먹다'와 'I eat rice'가 의미적으로 유사하므로 TRUE를 기대함
    SELECT kor_search_similar('I eat rice', '밥 먹다');  -- 결과: true

    -- '서울 살다'와 'She lives in Seoul'이 의미적으로 유사하므로 TRUE를 기대함
    SELECT kor_search_similar('She lives in Seoul', '서울 살다');  -- 결과: true

    -- '차가 빠르다'와 'The car is fast'가 의미적으로 유사하므로 TRUE를 기대함
    SELECT kor_search_similar('The car is fast', '차가 빠르다');  -- 결과: true
    ```

### kor_like

- `kor_like(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`에 포함되어 있는지 LIKE 쿼리로 확인합니다.

#### 사용 예시:

1. 단어 포함 여부 검사:

    ```sql
    -- 'lg' 키워드로 '엘지', '앨지'를 검색
    SELECT kor_like('이것은 엘지 제품입니다', 'lg');  -- 결과: true
    SELECT kor_like('이것은 LG 제품입니다', '엘지');  -- 결과: true

    -- 'apple' 키워드로 '애플', '사과'를 검색
    SELECT kor_like('애플은 훌륭한 과일입니다', 'apple');  -- 결과: true
    SELECT kor_like('사과를 좋아합니다', 'apple');  -- 결과: true
    SELECT kor_like('Apple은 과일입니다', '사과');  -- 결과: true
    ```

### kor_search_tsvector

- `kor_search_tsvector(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`의 tsvector에 포함되어 있는지 확인합니다.

#### 사용 예시:

1. tsvector를 사용한 유사 단어 검색:

    ```sql
    -- 'data science' 키워드로 '데이터 과학', '데이터 사이언스'를 검색
    SELECT kor_search_tsvector('데이터 과학은 미래의 유망한 분야입니다', 'data science');  -- 결과: true
    SELECT kor_search_tsvector('데이터 사이언스는 많은 가능성을 제공합니다', 'data science');  -- 결과: true
    SELECT kor_search_tsvector('Data Science는 많은 가능성을 제공합니다', '데이터 과학');  -- 결과: true

    -- 'machine learning' 키워드로 '머신러닝', '기계학습'을 검색
    SELECT kor_search_tsvector('머신러닝 기술이 발전하고 있습니다', 'machine learning');  -- 결과: true
    SELECT kor_search_tsvector('기계학습 알고리즘을 연구합니다', 'machine learning');  -- 결과: true
    SELECT kor_search_tsvector('Machine Learning 알고리즘을 연구합니다', '기계학습');  -- 결과: true
    ```

### kor_regex_search

- `kor_regex_search(input_text text, pattern text)`: 정규식 패턴이 `input_text`에 매칭되는지 확인합니다.

#### 사용 예시:

1. 정규식 검색:

    ```sql
    -- 정규식을 사용하여 특정 단어 패턴 검색
    SELECT kor_regex_search('자바는 강력한 언어입니다', '자바|파이썬');  -- 결과: true
    SELECT kor_regex_search('파이썬은 배우기 쉬운 언어입니다', '자바|파이썬');  -- 결과: true
    SELECT kor_regex_search('JAVA와 PYTHON은 인기있는 언어입니다', '(?i)자바|파이썬');  -- 결과: true

    -- 'big data'와 '대용량 데이터'를 정규식으로 검색
    SELECT kor_regex_search('빅데이터 분석이 중요합니다', '빅데이터|대용량 데이터');  -- 결과: true
    SELECT kor_regex_search('대용량 데이터를 처리합니다', '빅데이터|대용량 데이터');  -- 결과: true
    SELECT kor_regex_search('Big Data는 현대 기술의 핵심입니다', '(?i)빅데이터|대용량 데이터');  -- 결과: true
    ```

## 단어 변환 테이블 관리

단어 변환 테이블에 새로운 키워드와 유사어를 추가할 수 있습니다. 예를 들어, 'apple' 키워드에 대한 유사어를 추가하려면 다음과 같이 합니다:

```sql
INSERT INTO kor_search_word_transform (keyword)
VALUES ('apple');

INSERT INTO kor_search_word_synonyms (keyword_id, synonym)
VALUES ((SELECT id FROM kor_search_word_transform WHERE keyword = 'apple'), '애플');
```

## 제거

### 로컬 PostgreSQL 또는 EC2에서

로컬 PostgreSQL 또는 EC2에서 확장을 제거하려면 다음 단계를 따르세요:

1. PostgreSQL 데이터베이스에 접속합니다.

    ```sh
    psql -U your_username -d your_database
    ```

2. 확장을 제거합니다.

    ```sql
    DROP EXTENSION kor_search;
    ```

### Amazon RDS에서

Amazon RDS에서 확장을 제거하려면 다음 단계를 따르세요:

1. RDS 인스턴스에 접속합니다.

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `uninstall_kor_search.sql` 파일의 내용을 직접 실행하여 확장을 제거합니다:

    ```sql
    \i path/to/uninstall_kor_search.sql
    ```
