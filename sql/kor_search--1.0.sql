-- �ؽ�Ʈ ��ȯ �Լ� ����
CREATE OR REPLACE FUNCTION kor_like(input_text text, search_text text)
RETURNS boolean AS $$
BEGIN
    RETURN lower(input_text) LIKE '%' || lower(search_text) || '%';
END;
$$ LANGUAGE plpgsql;

-- tsvector �˻� �Լ� ����
CREATE OR REPLACE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector;
BEGIN
    vec := to_tsvector('korean', input_text);
    RETURN vec @@ plainto_tsquery('korean', search_text);
END;
$$ LANGUAGE plpgsql;