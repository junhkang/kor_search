<<<<<<< HEAD
=======
# kor_search

PostgreSQL용 한국어 텍스트 검색 확장.

## 설명

`kor_search` 확장은 한국어 텍스트 검색을 위해 LIKE 및 tsvector 기반 검색 기능을 제공합니다. 영어를 한글로 변환하여 LIKE 쿼리를 지원합니다.

## 설치

### 로컬 PostgreSQL 또는 EC2에서

1. 확장을 빌드하고 설치하려면 다음 명령어를 실행하세요:

    ```sh
    make
    sudo make install
    ```

2. 데이터베이스에서 확장을 사용하려면 다음 SQL을 실행하세요:

    ```sql
    CREATE EXTENSION kor_search;
    ```

### Amazon RDS에서

1. RDS 인스턴스에 접속합니다. 예를 들어, `psql`을 사용하여 접속할 수 있습니다:

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `kor_search--1.0.sql` 파일의 내용을 직접 실행합니다:

    ```sql
    \i path/to/kor_search--1.0.sql
    ```

## 함수

- `kor_like(input_text text, search_text text)`: `search_text`가 `input_text`에 포함되어 있는지 LIKE 쿼리로 확인합니다.
- `kor_search_tsvector(input_text text, search_text text)`: `search_text`가 `input_text`의 tsvector에 포함되어 있는지 확인합니다.

## 사용 예시

```sql
SELECT kor_like('안녕하세요', '안녕');  -- 결과: true

SELECT kor_search_tsvector('안녕하세요', '안녕');  -- 결과: true
>>>>>>> 1641cf0 (initial commit)
