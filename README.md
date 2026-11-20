<p align="right"><a href="localization/en/README.md">English</a></p>

# kor_search

**PostgreSQL에서 한영 혼용 텍스트를 검색하는 네이티브 확장입니다.** `samsung`으로 `삼성에서`를 찾고, 건설 사전을 선택하면 `RC`로 `철근콘크리트`를 찾습니다. Rust와 Lindera/ko-dic으로 문서를 분석하고 PostgreSQL 기본 GIN 인덱스를 사용합니다. 실행 시 외부 검색 서버나 API가 필요 없습니다.

## 설치

Linux, UTF-8 데이터베이스, PostgreSQL 16–18 및 해당 메이저 버전의 서버 개발 헤더, C 컴파일러, Make, Rust(rustup)가 필요합니다. 빌드 시 Cargo가 의존성과 ko-dic을 내려받습니다.

```bash
make PG_CONFIG=/path/to/pg_config
sudo make PG_CONFIG=/path/to/pg_config install
psql -X -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION kor_search;'
psql -X -v ON_ERROR_STOP=1 -f dictionaries/examples.sql # 선택: 예제 단어집
```

`pg_config`가 PATH에 있으면 `PG_CONFIG=...`는 생략합니다. PostgreSQL 서버에 바이너리와 SQL 설치 파일을 설치할 권한이 필요합니다. 자체 바이너리를 설치할 수 없는 RDS 등의 환경에서 2.0을 지원한다고 가정하지 마세요. 기존 RDS SQL 스크립트는 1.x 참고용이며 2.0 호환 경로가 아닙니다.

## 첫 검색

```sql
CREATE TABLE documents (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, body text NOT NULL);
INSERT INTO documents (body) VALUES ('삼성에서 PostgreSQL을 사용한다'), ('철근콘크리트 구조를 설계했다');
CREATE INDEX documents_search ON documents USING gin (kor_vector_v1(body));

PREPARE search_docs(text, text) AS
SELECT id, body FROM documents
WHERE kor_vector_v1(body) @@ (SELECT kor_search_tsquery($1, $2));

EXECUTE search_docs('samsung', 'general');
EXECUTE search_docs('RC', 'construction');
```

예제 단어집 기준입니다. `(SELECT ...)`는 쿼리당 한 번 검색어를 확장하고, 인덱스는 후보 행을 찾습니다. 문구 검색의 인덱스 재검사 비용이 크다면 `kor_vector_v1(body)`를 저장 생성 열로 만들고 그 열에 GIN을 만드세요.

| API | 동작 |
|---|---|
| `kor_analyze_v1(text)` | NFC 정규화 및 형태소 분석 결과를 공백 단위로 확인합니다. |
| `kor_vector_v1(text)` | 문서를 버전이 고정된 `tsvector`로 바꿉니다. GIN 표현식에 사용할 수 있습니다. |
| `kor_search_tsquery(text, scope DEFAULT 'general')` | 일반 텍스트를 분석해 사전을 확장합니다. 빈 검색어는 NULL입니다. |

## 업무 단어집

설치 시 2.0 사전은 비어 있습니다. 등록된 표현 중 가장 긴 문구를 먼저 찾고, 같은 범위·개념의 표현을 OR로, 나머지 토큰 그룹을 AND로 묶습니다. 등록하지 않은 단어는 자기 자신으로 검색됩니다. 문구는 분석 후 토큰 순서로 판단합니다. 사전을 변경해도 문서 재색인은 필요 없습니다.

```sql
INSERT INTO kor_search_aliases (scope, concept, term, kind) VALUES
    ('construction', 'job-site', '공사 현장', 'label'),
    ('construction', 'job-site', 'job site', 'translation');
```

같은 범위에서 정규화된 표현은 하나의 개념에만 속합니다. `apple`을 기술·소매 범위에 별도로 등록하는 예는 예제 사전을 참고하세요. 범위는 **사전 선택**일 뿐 문서 필터나 접근 제어가 아닙니다. 검색 계정에는 확장 스키마의 `USAGE`와 별칭 테이블의 `SELECT` 권한을 따로 부여하세요. 사전 팩 기여 시 출처와 재배포 가능 여부를 명시해 주세요.

한국어 분석은 오탐을 모두 제거하지 않습니다(예: 서울역이 서울로 검색될 수 있음). 부분 문자열·초성·자동 번역·영어 어간 검색은 지원하지 않습니다. 최대 문서 512 KiB, 검색어 4 KiB/64 토큰, 별칭 문구 8 토큰, 개념당 검색 확장 32개입니다. PostgreSQL `tsvector`의 토큰 및 위치 한도도 적용됩니다.

## 업그레이드 및 검증

- 기존 서버에 새 빌드를 설치하고 유지보수 시간에 **기존 연결을 재시작/재연결**한 뒤 `ALTER EXTENSION kor_search UPDATE TO '2.0.0';`를 실행하세요. 중간 버전으로 별도 업데이트할 필요는 없습니다.
- 기존 함수 네 개와 레거시 테이블은 유지됩니다. 새 검색에 사용할 업무 용어는 범위·개념을 검토한 뒤 별칭 테이블에 등록하세요. 1.x 기본 행을 직접 수정·삭제했다면 일반 `pg_dump`에서 복원되지 않으므로 두 레거시 테이블을 별도로 백업하세요. 자동 테스트는 추가 행과 새 별칭의 복원을 확인합니다.
- 설치 시 사용자 지정 스키마를 선택할 수 있지만 2.0 설치 후에는 `ALTER EXTENSION ... SET SCHEMA`를 지원하지 않습니다. 향후 분석 규칙이 바뀌면 새 버전 함수와 인덱스를 병행할 계획입니다.
- `bash test/run.sh`로 설치·업그레이드·복원을 검증합니다. [평가셋과 벤치마크](bench/README.md) · [변경 내역](CHANGELOG.md).
