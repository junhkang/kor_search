-- kor_search_data.sql

-- 단어 변환 테이블 생성
CREATE TABLE IF NOT EXISTS kor_search_word_transform (
    id serial PRIMARY KEY,
    keyword text
);

-- 유사어 테이블 생성
CREATE TABLE IF NOT EXISTS kor_search_word_synonyms (
    id serial PRIMARY KEY,
    keyword_id int REFERENCES kor_search_word_transform(id) ON DELETE CASCADE,
    synonym text
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_kor_search_keyword ON kor_search_word_transform (keyword);
CREATE INDEX IF NOT EXISTS idx_kor_search_synonyms ON kor_search_word_synonyms (synonym);
CREATE INDEX IF NOT EXISTS trgm_idx_kor_search_word_synonyms ON kor_search_word_synonyms USING gin (synonym gin_trgm_ops);

-- 키워드 삽입
INSERT INTO kor_search_word_transform (keyword)
VALUES
('lg'),
('samsung'),
('apple'),
('google'),
('microsoft'),
('hyundai'),
('kia'),
('naver'),
('kakao'),
('sk'),
('seoul'),
('busan'),
('java'),
('python'),
('machine learning'),
('artificial intelligence'),
('big data'),
('data science'),
('deep learning');

-- 유사어 삽입
INSERT INTO kor_search_word_synonyms (keyword_id, synonym)
VALUES
((SELECT id FROM kor_search_word_transform WHERE keyword = 'lg'), '엘지'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'lg'), '앨지'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'samsung'), '삼성'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'apple'), '애플'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'apple'), '사과'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'google'), '구글'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'microsoft'), '마이크로소프트'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'hyundai'), '현대'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'kia'), '기아'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'naver'), '네이버'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'kakao'), '카카오'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sk'), '에스케이'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sk'), 'SK'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'seoul'), '서울'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'seoul'), '서울특별시'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'busan'), '부산'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'java'), '자바'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'python'), '파이썬'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'machine learning'), '머신러닝'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'machine learning'), '기계학습'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'artificial intelligence'), '인공지능'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'artificial intelligence'), 'AI'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'big data'), '빅데이터'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'big data'), '대용량 데이터'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'data science'), '데이터 과학'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'data science'), '데이터 사이언스'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'deep learning'), '딥러닝'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'deep learning'), '심층 학습');

CREATE FUNCTION kor_search_like(input_text text, search_text text)
RETURNS boolean
AS 'kor_search', 'kor_search_like'
LANGUAGE C STRICT;

CREATE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean
AS 'kor_search', 'kor_search_tsvector'
LANGUAGE C STRICT;

CREATE FUNCTION kor_search_regex(input_text text, pattern text)
RETURNS boolean
AS 'kor_search', 'kor_search_regex'
LANGUAGE C STRICT;