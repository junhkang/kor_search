-- kor_search--1.0.sql
-- 단어 변환 테이블 생성
CREATE TABLE IF NOT EXISTS kor_search_word_transform (
    id serial PRIMARY KEY,
    keyword text,
    synonyms text[]
);

-- 초기 데이터 삽입
INSERT INTO kor_search_word_transform (keyword, synonyms)
VALUES
('lg', ARRAY['엘지', '앨지']),
('samsung', ARRAY['삼성']);

-- LIKE 검색 함수 생성
CREATE OR REPLACE FUNCTION kor_like(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    synonym text;
    keyword_found boolean := false;
BEGIN
    -- search_text에 해당하는 synonyms 검색
    FOR synonym IN
        SELECT unnest(synonyms)
        FROM kor_search_word_transform
        WHERE keyword = lower(search_text)
    LOOP
        IF lower(input_text) LIKE '%' || lower(synonym) || '%' THEN
            keyword_found := true;
            EXIT;
        END IF;
    END LOOP;

    RETURN keyword_found;
END;
$$ LANGUAGE plpgsql;

-- tsvector 검색 함수 생성
CREATE OR REPLACE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector;
    synonym text;
    keyword_found boolean := false;
BEGIN
    -- search_text에 해당하는 synonyms 검색
    FOR synonym IN
        SELECT unnest(synonyms)
        FROM kor_search_word_transform
        WHERE keyword = lower(search_text)
    LOOP
        vec := to_tsvector('english', input_text);
        IF vec @@ plainto_tsquery('english', synonym) THEN
            keyword_found := true;
            EXIT;
        END IF;
    END LOOP;

    RETURN keyword_found;
END;
$$ LANGUAGE plpgsql;
