-- 초기 데이터 삽입
INSERT INTO kor_search_word_transform (keyword, synonyms)
VALUES
('lg', ARRAY['엘지', '앨지']),
('samsung', ARRAY['삼성']),
('apple', ARRAY['애플', '사과']),
('google', ARRAY['구글']),
('microsoft', ARRAY['마이크로소프트']),
('hyundai', ARRAY['현대']),
('kia', ARRAY['기아']),
('naver', ARRAY['네이버']),
('kakao', ARRAY['카카오']),
('sk', ARRAY['에스케이', 'SK']),
('seoul', ARRAY['서울', '서울특별시']),
('busan', ARRAY['부산']),
('java', ARRAY['자바']),
('python', ARRAY['파이썬']),
('machine learning', ARRAY['머신러닝', '기계학습']),
('artificial intelligence', ARRAY['인공지능', 'AI']),
('big data', ARRAY['빅데이터', '대용량 데이터']),
('data science', ARRAY['데이터 과학', '데이터 사이언스']),
('deep learning', ARRAY['딥러닝', '심층 학습']);

