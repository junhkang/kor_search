CREATE EXTENSION kor_search;
\ir ../dictionaries/examples.sql
\ir ../dictionaries/examples.sql

DO $$ BEGIN
    IF (SELECT extversion FROM pg_extension WHERE extname = 'kor_search') <> '2.0.0'
        OR EXISTS (SELECT FROM pg_extension WHERE extname = 'pg_trgm') THEN
        RAISE EXCEPTION 'unexpected default install version or dependency';
    END IF;
    IF kor_analyze_v1('삼성에서 Samsung') <> '삼성 samsung'
        OR kor_analyze_v1(normalize('철근 콘크리트', NFD)) <> kor_analyze_v1('철근 콘크리트')
        OR NOT (kor_vector_v1('철근콘크리트 구조 설계') @@ kor_search_tsquery('rc', 'construction'))
        OR NOT (kor_vector_v1('Reinforced concrete structure') @@ kor_search_tsquery('철근 콘크리트', 'construction'))
        OR NOT (kor_vector_v1('삼성에서 PostgreSQL 사용') @@ kor_search_tsquery('Samsung PostgreSQL'))
        OR kor_vector_v1('삼성동에서 약속') @@ kor_search_tsquery('Samsung')
        OR kor_vector_v1('The concrete is not reinforced') @@ kor_search_tsquery('RC', 'construction')
        OR kor_vector_v1('data and science') @@ kor_search_tsquery('데이터 과학')
        OR kor_vector_v1('사과를 주문했다') @@ kor_search_tsquery('apple', 'technology')
        OR kor_vector_v1('애플이 출시했다') @@ kor_search_tsquery('apple', 'retail')
        OR kor_search_tsquery('! | .') IS NOT NULL
        OR kor_search_tsquery(NULL) IS NOT NULL THEN
        RAISE EXCEPTION 'native analyzer or query regression';
    END IF;

    BEGIN
        PERFORM kor_search_tsquery(repeat('samsung ', 65));
        RAISE EXCEPTION 'expected token limit';
    EXCEPTION WHEN program_limit_exceeded THEN NULL;
    END;

    BEGIN
        INSERT INTO kor_search_aliases(scope, concept, term, kind)
        VALUES ('technology', 'unrelated-concept', 'APPLE', 'label');
        RAISE EXCEPTION 'expected scope ambiguity to be rejected';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
END $$;

CREATE TABLE documents (id int PRIMARY KEY, body text NOT NULL);
INSERT INTO documents VALUES (1, '삼성에서 PostgreSQL 사용'), (2, '서울에서 PostgreSQL 사용');
CREATE INDEX documents_search ON documents USING gin (kor_vector_v1(body));

INSERT INTO kor_search_aliases(scope, concept, term, kind)
VALUES ('general', 'samsung', '삼성그룹', 'synonym');

SET enable_seqscan = off;
DO $$
DECLARE plan text;
BEGIN
    EXECUTE 'EXPLAIN (COSTS OFF, FORMAT JSON) SELECT id FROM documents
             WHERE kor_vector_v1(body) @@ (SELECT kor_search_tsquery(''삼성그룹''))' INTO plan;
    IF plan NOT LIKE '%"Index Name": "documents_search"%'
        OR (SELECT array_agg(id) FROM documents
            WHERE kor_vector_v1(body) @@ (SELECT kor_search_tsquery('삼성그룹'))) IS DISTINCT FROM ARRAY[1] THEN
        RAISE EXCEPTION 'alias added after indexing did not use the existing index or match';
    END IF;
END $$;
RESET enable_seqscan;
