-- kor_search--1.0.sql
-- 단어 변환 테이블 생성
CREATE TABLE IF NOT EXISTS kor_search_word_transform (
    id serial PRIMARY KEY,
    keyword text,
    synonyms text[]
);
-- keyword 컬럼에 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_kor_search_keyword ON kor_search_word_transform (keyword);

-- synonyms 배열의 각 요소에 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_kor_search_synonyms ON kor_search_word_transform USING gin (synonyms);

-- 초기 데이터 삽입
\i kor_search_data.sql

-- LIKE 검색 함수 생성
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

-- tsvector 검색 함수 생성
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


-- 정규식 검색 함수 생성
CREATE OR REPLACE FUNCTION kor_regex_search(input_text text, pattern text)
RETURNS boolean AS $$
BEGIN
    RETURN input_text ~* pattern;
END;
$$ LANGUAGE plpgsql;
