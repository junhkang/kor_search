# kor_search

PostgreSQL용 한국어 텍스트 검색 확장.

## 설명

`kor_search` 확장은 한국어 텍스트 검색을 위해 LIKE, tsvector, 정규식 검색 기능을 제공합니다. 영어를 한글로 변환하여 LIKE 쿼리를 지원합니다.

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

2. `kor_search--1.0.sql` 파일의 내용을 직접 실행하여 확장을 활성화합니다:

    ```sql
    \i path/to/kor_search--1.0.sql
    ```

## 함수

- `kor_like(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`에 포함되어 있는지 LIKE 쿼리로 확인합니다.
- `kor_search_tsvector(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`의 tsvector에 포함되어 있는지 확인합니다.
- `kor_regex_search(input_text text, pattern text)`: 정규식 패턴이 `input_text`에 매칭되는지 확인합니다.

## 사용 예시

1. `kor_like` 함수 사용 예시:

    ```sql
    -- 'lg' 키워드로 '엘지', '앨지'를 검색
    SELECT kor_like('이것은 엘지 제품입니다', 'lg');  -- 결과: true
    SELECT kor_like('이것은 LG 제품입니다', '엘지');  -- 결과: true

    -- 'apple' 키워드로 '애플', '사과'를 검색
    SELECT kor_like('애플은 훌륭한 과일입니다', 'apple');  -- 결과: true
    SELECT kor_like('사과를 좋아합니다', 'apple');  -- 결과: true
    SELECT kor_like('Apple은 과일입니다', '사과');  -- 결과: true
    ```

2. `kor_search_tsvector` 함수 사용 예시:

    ```sql
    -- 'data science' 키워드로 '데이터 과학', '데이터 사이언스'를 검색
    SELECT kor_search_tsvector('데이터 과학은 미래의 유망한 분야입니다', 'data science');  -- 결과: true
    SELECT kor_search_tsvector('데이터 사이언스는 많은 가능성을 제공합니다', 'data science');  -- 결과: true
    SELECT kor_search_tsvector('Data Science는 많은 가능성을 제공합니다', '데이터 과학');  -- 결과: true

    -- 'machine learning' 키워드로 '머신러닝', '기계학습'을 검색
    SELECT kor_search_tsvector('머신러닝 기술이 발전하고 있습니다', 'machine learning');  -- 결과: true
    SELECT kor_search_tsvector('기계학습 알고리즘을 연구합니다', 'machine learning');  -- 결과: true
    SELECT kor_search_tsvector('Machine Learning 알고리즘을 연구합니다', '기계학습');  -- 결과: true

    -- 'seoul' 키워드로 '서울', '서울특별시'를 검색
    SELECT kor_search_tsvector('서울은 대한민국의 수도입니다', 'seoul');  -- 결과: true
    SELECT kor_search_tsvector('서울특별시는 한국의 수도입니다', 'seoul');  -- 결과: true
    SELECT kor_search_tsvector('서울 시내를 돌아다녔습니다', 'seoul');  -- 결과: true
    ```

3. `kor_regex_search` 함수 사용 예시:

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
INSERT INTO kor_search_word_transform (keyword, synonyms)
VALUES ('apple', ARRAY['애플', '사과']);
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
