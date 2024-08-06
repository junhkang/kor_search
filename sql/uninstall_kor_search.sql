-- uninstall_kor_search.sql
DROP FUNCTION IF EXISTS kor_like(text, text);
DROP FUNCTION IF EXISTS kor_search_tsvector(text, text);
DROP INDEX IF EXISTS idx_kor_search_keyword;
DROP INDEX IF EXISTS idx_kor_search_synonyms;
DROP TABLE IF EXISTS kor_search_word_transform;