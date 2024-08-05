-- kor_search--1.0.sql
-- �ܾ� ��ȯ ���̺� ����
CREATE TABLE IF NOT EXISTS kor_search_word_transform (
    id serial PRIMARY KEY,
    keyword text,
    synonyms text[]
);

-- �ʱ� ������ ����
INSERT INTO kor_search_word_transform (keyword, synonyms)
VALUES
('lg', ARRAY['����', '����']),
('samsung', ARRAY['�Ｚ']);

-- LIKE �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_like(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    synonym text;
    keyword_found boolean := false;
BEGIN
    -- search_text�� �ش��ϴ� synonyms �˻�
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

-- tsvector �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector;
    synonym text;
    keyword_found boolean := false;
BEGIN
    -- search_text�� �ش��ϴ� synonyms �˻�
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
