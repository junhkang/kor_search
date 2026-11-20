# Reproduce the search benchmark

Run from the repository root against a disposable UTF-8 database with permission to create the extension:

```bash
createdb kor_search_bench
psql -X -v ON_ERROR_STOP=1 -d kor_search_bench -f bench/compare.sql
dropdb kor_search_bench
```

Use `-v rows=1000000` to increase the performance corpus. The [labeled fixture](fixtures.sql) contains 24 original documents and 15 queries. The comparison is against standard PostgreSQL `simple` FTS and GIN with manually constructed queries using the same aliases plus Korean prefix matching. This measures match-set precision/recall, not ranking. Both systems index stored generated vectors. The native latency includes dictionary expansion once per query; baseline terms are pre-expanded. The performance corpus repeats fixture documents with distractors rather than representing production text. Results are warm, single-session timings, with no network time.

## Example: PG 17.12 on Linux x86-64

| Metric | Standard GIN + prefix | kor_search 2.0 |
|---|---:|---:|
| Match precision | 85.7% | 94.7% |
| Match recall | 100% | 100% |
| False positives | 6 | 2 |
| Search p95 (210 samples per path) | 0.897 ms | 0.914 ms |
| Load 100k rows and compute stored vectors | 322 ms | 1,003 ms |
| Build GIN over stored vectors | 82 ms | 94 ms |
| Insert 1,000 rows with GIN | 10.8 ms | 20.9 ms |
| GIN size after vacuum | 928 KiB | 1,040 KiB |

Both plans used GIN. The native analyzer avoids `삼성동` for `삼성` and `서울대` for `서울` on this fixture, but still matches `서울역` for `서울`. The result supports improved retrieval precision at similar warm search latency here, with higher write cost. It does not establish a throughput advantage for production workloads. The compiled module is about 90 MiB on this machine, mostly read-only embedded dictionary data; those file-backed pages are shareable across PostgreSQL backends.
