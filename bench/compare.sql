-- Run against a disposable UTF-8 database: psql -X -v ON_ERROR_STOP=1 -f bench/compare.sql
\if :{?rows}
\else
  \set rows 100000
\endif
CREATE EXTENSION IF NOT EXISTS kor_search;
\ir ../dictionaries/examples.sql
\ir fixtures.sql
SET jit = off;
SET max_parallel_workers_per_gather = 0;

CREATE TEMP TABLE query_pairs AS
SELECT q.*, kor_search_tsquery(q.q, q.scope) AS native FROM evaluation_queries q;
CREATE TEMP TABLE predictions AS
SELECT q.id, q.q, q.expected,
       ARRAY(SELECT id FROM evaluation_documents WHERE kor_vector_v1(body) @@ q.native ORDER BY id) AS native,
       ARRAY(SELECT id FROM evaluation_documents WHERE to_tsvector('pg_catalog.simple', body) @@ q.baseline ORDER BY id) AS baseline
FROM query_pairs q;
TABLE predictions;

SELECT method, tp, fp, fn, round(tp::numeric / NULLIF(tp + fp, 0), 3) AS precision,
       round(tp::numeric / NULLIF(tp + fn, 0), 3) AS recall
FROM (
    SELECT method, sum(cardinality(ARRAY(SELECT unnest(actual) INTERSECT SELECT unnest(expected)))) AS tp,
           sum(cardinality(ARRAY(SELECT unnest(actual) EXCEPT SELECT unnest(expected)))) AS fp,
           sum(cardinality(ARRAY(SELECT unnest(expected) EXCEPT SELECT unnest(actual)))) AS fn
    FROM predictions, LATERAL (VALUES ('native', native), ('baseline', baseline)) AS p(method, actual)
    GROUP BY method
) AS metrics ORDER BY method;

CREATE TEMP TABLE originals AS
SELECT i AS id, CASE WHEN i % 100 = 0 THEN d.body ELSE
        CASE i % 4 WHEN 0 THEN '시스템에서 매일 상태를 점검한다'
            WHEN 1 THEN 'The routine maintenance report is ready'
            WHEN 2 THEN '기술팀이 network 점검을 진행했다'
            ELSE 'The editor reviewed a quarterly report' END
        END AS body
FROM generate_series(0, :rows - 1) AS i
JOIN evaluation_documents d ON d.id = 1 + (i / 100) % 24;

CREATE TEMP TABLE kor_docs (body text, lexemes tsvector GENERATED ALWAYS AS (kor_vector_v1(body)) STORED);
CREATE TEMP TABLE pg_docs (body text, lexemes tsvector GENERATED ALWAYS AS (to_tsvector('pg_catalog.simple', body)) STORED);
\timing on
\echo Native initial load:
INSERT INTO kor_docs (body) SELECT body FROM originals;
\echo Baseline initial load:
INSERT INTO pg_docs (body) SELECT body FROM originals;
\echo Native GIN build:
CREATE INDEX kor_docs_gin ON kor_docs USING gin (lexemes);
\echo Baseline GIN build:
CREATE INDEX pg_docs_gin ON pg_docs USING gin (lexemes);
\echo Native indexed insert (1,000 rows on a 100,000-row run):
INSERT INTO kor_docs (body) SELECT body FROM originals WHERE id < 1000;
\echo Baseline indexed insert (same rows):
INSERT INTO pg_docs (body) SELECT body FROM originals WHERE id < 1000;
\timing off
VACUUM ANALYZE kor_docs;
VACUUM ANALYZE pg_docs;
SELECT pg_relation_size('kor_docs_gin') AS native_index_bytes, pg_relation_size('pg_docs_gin') AS baseline_index_bytes;
EXPLAIN (COSTS OFF) SELECT count(*) FROM kor_docs WHERE lexemes @@ (SELECT kor_search_tsquery('samsung'));
EXPLAIN (COSTS OFF) SELECT count(*) FROM pg_docs WHERE lexemes @@ ('samsung | 삼성:*')::tsquery;

CREATE TEMP TABLE samples (method text, query_id int, matches bigint, ms double precision);
DO $$
DECLARE
    pair record;
    start_time timestamptz;
    hits bigint;
    sample_ms double precision;
BEGIN
    FOR run IN 0..30 LOOP
        FOR pair IN SELECT * FROM query_pairs WHERE id IN (1, 3, 4, 6, 9, 11, 12) ORDER BY id LOOP
            start_time := clock_timestamp();
            SELECT count(*) INTO hits FROM kor_docs WHERE lexemes @@ (SELECT kor_search_tsquery(pair.q, pair.scope));
            sample_ms := extract(epoch FROM clock_timestamp() - start_time) * 1000;
            IF run > 0 THEN INSERT INTO samples VALUES ('native', pair.id, hits, sample_ms); END IF;

            start_time := clock_timestamp();
            SELECT count(*) INTO hits FROM pg_docs WHERE lexemes @@ pair.baseline;
            sample_ms := extract(epoch FROM clock_timestamp() - start_time) * 1000;
            IF run > 0 THEN INSERT INTO samples VALUES ('baseline', pair.id, hits, sample_ms); END IF;
        END LOOP;
    END LOOP;
END $$;
SELECT method, count(*) AS runs, round(percentile_cont(0.95) WITHIN GROUP (ORDER BY ms)::numeric, 3) AS p95_ms
FROM samples GROUP BY method ORDER BY method;
SELECT query_id, method, min(matches) AS matches,
       round(percentile_cont(0.95) WITHIN GROUP (ORDER BY ms)::numeric, 3) AS p95_ms
FROM samples GROUP BY query_id, method ORDER BY query_id, method;
