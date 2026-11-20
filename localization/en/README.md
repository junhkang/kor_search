[한국어](../../README.md)

# kor_search

A native PostgreSQL extension for mixed Korean and English search. Analyze documents with Rust and Lindera/ko-dic, index them with built-in GIN, and expand query terms using a domain dictionary. For example, `samsung` can match `삼성에서`, and `RC` can match `철근콘크리트`. No external service is used at runtime.

## Install

Tested on Linux with UTF-8 databases and PostgreSQL 16–18. Install matching PostgreSQL server headers, Make, a C compiler, and Rust via rustup. The build downloads Rust dependencies and ko-dic. Use `make PG_CONFIG=/path/to/pg_config` and then `sudo make PG_CONFIG=/path/to/pg_config install`. If the intended `pg_config` is already on PATH, omit the override.

```bash
psql -X -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION kor_search;'
psql -X -v ON_ERROR_STOP=1 -f dictionaries/examples.sql
```

```sql
CREATE TABLE documents (body text NOT NULL);
INSERT INTO documents VALUES ('삼성에서 PostgreSQL을 사용한다'), ('철근콘크리트 구조를 설계했다');
CREATE INDEX documents_search ON documents USING gin (kor_vector_v1(body));
SELECT body FROM documents
WHERE kor_vector_v1(body) @@ (SELECT kor_search_tsquery('RC', 'construction'));
```

`kor_analyze_v1` shows the analyzed token stream. `kor_vector_v1` produces a positional `tsvector`. `kor_search_tsquery(query, scope)` expands the longest dictionary phrase first, ORs its aliases and ANDs the resulting groups. Empty input after analysis yields NULL. If phrase rechecks become expensive, use GIN on a stored generated vector column.

Add rows to `kor_search_aliases(scope, concept, term, kind)` or load the [optional example dictionary](../../dictionaries/examples.sql). A normalized term can belong to only one concept in a scope. Alias updates do not require a document reindex. Scope selects a dictionary, not which documents or users can be searched. Search users need schema `USAGE` and alias-table `SELECT`. The analyzer does not implement arbitrary substring search, automatic translation, or English stemming. Limits: 512 KiB per document, 4 KiB or 64 analyzed tokens per query, eight tokens per alias, and 32 expansions per concept.

## Upgrade

Install the new binaries and scripts, reconnect any existing database sessions during a maintenance window, and run `ALTER EXTENSION kor_search UPDATE TO '2.0.0';`. Legacy functions and tables remain available. Review and copy domain terms to the new dictionary explicitly; legacy seed edits and deletes require a separate data backup. 2.0 can be installed into a custom schema but cannot be relocated afterwards. Managed services without native-module install access are not supported by this build.

Run `bash test/run.sh` from a role that can create databases and extensions. See [benchmarks](../../bench/README.md) and the [changelog](../../CHANGELOG.md).
