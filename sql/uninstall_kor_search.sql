-- uninstall_kor_search.sql
DROP FUNCTION IF EXISTS kor_like(text, text);
DROP FUNCTION IF EXISTS kor_search_tsvector(text, text);