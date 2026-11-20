CREATE SCHEMA "search utils";
CREATE EXTENSION kor_search WITH SCHEMA "search utils" VERSION '1.0.0' CASCADE;
INSERT INTO "search utils".kor_search_word_transform (keyword) VALUES ('contractor');
INSERT INTO "search utils".kor_search_word_synonyms (keyword_id, synonym)
SELECT id, '도급업체' FROM "search utils".kor_search_word_transform WHERE keyword = 'contractor';
BEGIN;
ALTER EXTENSION kor_search UPDATE TO '1.1.0';
DO $$ BEGIN
    IF NOT "search utils".kor_search_like('도급업체를 선정했다', 'contractor') THEN
        RAISE EXCEPTION 'legacy lookup after a 1.1.0 upgrade failed';
    END IF;
END $$;
ROLLBACK;
ALTER EXTENSION kor_search UPDATE;
DROP EXTENSION pg_trgm;
INSERT INTO "search utils".kor_search_aliases(scope, concept, term, kind) VALUES
    ('example', 'contractor', 'contractor', 'label'),
    ('example', 'contractor', '도급업체', 'translation');
