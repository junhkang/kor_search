DROP INDEX IF EXISTS trgm_idx_kor_search_word_synonyms;
CREATE INDEX idx_kor_search_synonyms_keyword ON kor_search_word_synonyms (keyword_id);

-- The install script recreates the original seed rows with these IDs.
SELECT pg_catalog.pg_extension_config_dump('kor_search_word_transform', 'WHERE id NOT BETWEEN 1 AND 171');
SELECT pg_catalog.pg_extension_config_dump('kor_search_word_synonyms', 'WHERE id NOT BETWEEN 1 AND 168');

ALTER FUNCTION kor_search_like(text, text) STABLE;
ALTER FUNCTION kor_search_similar(text, text) STABLE;
ALTER FUNCTION kor_search_tsvector(text, text) STABLE;
ALTER FUNCTION kor_search_regex(text, text) STABLE;
