# kor_search

PostgreSQL용 한국어 텍스트 검색 확장.

## 설명

`kor_search` 확장은 한국어 텍스트 검색을 위해 LIKE 및 tsvector 기반 검색 기능을 제공합니다. 영어를 한글로 변환하여 LIKE 쿼리를 지원합니다.

## 설치

### 로컬 PostgreSQL 또는 EC2에서

1. 먼저 PostgreSQL 확장을 빌드하고 설치하려면 다음 명령어를 실행하세요:

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

3. 초기 데이터를 삽입하려면 `kor_search_data.sql` 파일의 내용을 실행합니다:

    ```sql
    \i path/to/kor_search_data.sql
    ```

## 함수

- `kor_like(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`에 포함되어 있는지 LIKE 쿼리로 확인합니다.
- `kor_search_tsvector(input_text text, search_text text)`: `search_text`에 해당하는 synonyms가 `input_text`의 tsvector에 포함되어 있는지 확인합니다.

## 사용 예시

1. `kor_like` 함수 사용 예시:

    ```sql
    -- 'lg' 키워드로 '엘지', '앨지'를 검색
    SELECT kor_like('이것은 엘지 제품입니다', 'lg');  -- 결과: true
    SELECT kor_like('이것은 앨지 제품입니다', 'lg');  -- 결과: true

    -- 'samsung' 키워드로 '삼성'을 검색
    SELECT kor_like('이것은 삼성 제품입니다', 'samsung');  -- 결과: true
    ```

2. `kor_search_tsvector` 함수 사용 예시:

    ```sql
    -- 'lg' 키워드로 '엘지', '앨지'를 검색
    SELECT kor_search_tsvector('이것은 엘지 제품입니다', 'lg');  -- 결과: true
    SELECT kor_search_tsvector('이것은 앨지 제품입니다', 'lg');  -- 결과: true

    -- 'samsung' 키워드로 '삼성'을 검색
    SELECT kor_search_tsvector('이것은 삼성 제품입니다', 'samsung');  -- 결과: true
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
