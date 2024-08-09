-- uninstall_kor_search.sql
DROP FUNCTION IF EXISTS kor_search_like(text, text);
DROP FUNCTION IF EXISTS kor_search_tsvector(text, text);
DROP FUNCTION IF EXISTS kor_regex_search(text, text);
DROP TABLE IF EXISTS kor_search_word_synonyms;
DROP TABLE IF EXISTS kor_search_word_transform;
