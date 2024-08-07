\i kor_search_data.sql

-- LIKE 검색 함수
CREATE OR REPLACE FUNCTION kor_like_search(input_text text, search_text text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM kor_search_word_synonyms
        JOIN kor_search_word_transform ON kor_search_word_synonyms.keyword_id = kor_search_word_transform.id
        WHERE kor_search_word_transform.keyword = lower(unaccent(search_text))
          AND similarity(input_text, kor_search_word_synonyms.synonym) >= 0.3
    );
END;
$$ LANGUAGE plpgsql;


-- tsvector 검색 함수
CREATE OR REPLACE FUNCTION kor_tsvector_search(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector := to_tsvector('english', input_text);
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM kor_search_word_synonyms
        JOIN kor_search_word_transform ON kor_search_word_synonyms.keyword_id = kor_search_word_transform.id
        WHERE kor_search_word_transform.keyword = lower(unaccent(search_text))
          AND similarity(vec::text, kor_search_word_synonyms.synonym) >= 0.3
    );
END;
$$ LANGUAGE plpgsql;


-- 정규식 검색 함수 생성
CREATE OR REPLACE FUNCTION kor_regex_search(input_text text, pattern text)
RETURNS boolean AS $$
BEGIN
    RETURN input_text ~* pattern;
END;
$$ LANGUAGE plpgsql;