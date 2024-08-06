-- kor_search--1.0.sql
-- �ܾ� ��ȯ ���̺� ����
CREATE TABLE IF NOT EXISTS kor_search_word_transform (
    id serial PRIMARY KEY,
    keyword text,
    synonyms text[]
);
-- keyword �÷��� �ε��� ����
CREATE INDEX IF NOT EXISTS idx_kor_search_keyword ON kor_search_word_transform (keyword);

-- synonyms �迭�� �� ��ҿ� �ε��� ����
CREATE INDEX IF NOT EXISTS idx_kor_search_synonyms ON kor_search_word_transform USING gin (synonyms);

-- �ʱ� ������ ����
\i kor_search_data.sql

-- LIKE �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_like(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    synonym text;
BEGIN
    FOR synonym IN
        SELECT unnest(synonyms)
        FROM kor_search_word_transform
        WHERE keyword = lower(search_text)
    LOOP
        IF lower(input_text) LIKE '%' || lower(synonym) || '%' THEN
            RETURN true;
        END IF;
    END LOOP;

    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- tsvector �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector;
    synonym text;
BEGIN
    vec := to_tsvector('english', input_text);

    FOR synonym IN
        SELECT unnest(synonyms)
        FROM kor_search_word_transform
        WHERE keyword = lower(search_text)
    LOOP
        IF vec @@ plainto_tsquery('english', synonym) THEN
            RETURN true;
        END IF;
    END LOOP;

    RETURN false;
END;
$$ LANGUAGE plpgsql;


-- ���Խ� �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_regex_search(input_text text, pattern text)
RETURNS boolean AS $$
BEGIN
    RETURN input_text ~* pattern;
END;
$$ LANGUAGE plpgsql;
