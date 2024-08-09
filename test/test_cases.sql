-- kor_search_like 테스트
\echo 'Running kor_search_like tests...'
ASSERT (SELECT kor_search_like('나는 밥을 먹었다', '밥')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('I eat rice', '밥')) = FALSE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('서울은 한국의 수도이다', '서울')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('I work at Microsoft', 'Microsoft')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('나는 마이크로소프트에 취업했어', 'Microsoft')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('나는 삼성에서 일해', 'Samsung')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('He lives in Seoul', '서울')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('He lives in New York', '서울')) = FALSE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('I like apples', '사과')) = TRUE, 'kor_search_like test failed';
ASSERT (SELECT kor_search_like('He studies at Harvard', 'Harvard')) = TRUE, 'kor_search_like test failed';

-- kor_search_similar 테스트
\echo 'Running kor_search_similar tests...'
ASSERT (SELECT kor_search_similar('I eat rice', '밥 먹다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('I go to school', '학교')) = FALSE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('He eats lunch', '점심 먹다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('She reads a book', '책 읽다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('The car is fast', '차')) = FALSE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('He is studying at university', '대학 공부하다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('She lives in Seoul', '서울 살다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('He travels by train', '기차 여행하다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('He eats an apple', '사과 먹다')) = TRUE, 'kor_search_similar test failed';
ASSERT (SELECT kor_search_similar('The sun is shining', '햇빛')) = TRUE, 'kor_search_similar test failed';

-- kor_search_tsvector 테스트
\echo 'Running kor_search_tsvector tests...'
ASSERT (SELECT kor_search_tsvector('I eat rice', '밥 먹다')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('I go to school', '학교')) = FALSE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('He reads books', '책 읽다')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('The car is fast', '차')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('She enjoys running', '달리기')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('They are playing football', '축구하다')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('He eats an orange', '오렌지 먹다')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('The moon is bright', '달')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('She is cooking dinner', '저녁 요리하다')) = TRUE, 'kor_search_tsvector test failed';
ASSERT (SELECT kor_search_tsvector('The computer is fast', '컴퓨터')) = TRUE, 'kor_search_tsvector test failed';

-- kor_search_regex 테스트
\echo 'Running kor_search_regex tests...'
ASSERT (SELECT kor_search_regex('I have 2 apples', '[0-9]+ 사과')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('There are no apples', '[0-9]+ 사과')) = FALSE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('My phone number is 1234', '[0-9]+ 전화번호')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('There are 10 oranges', '[0-9]+ 오렌지')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('I have no fruits', '[0-9]+ 과일')) = FALSE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('The car is red', '[a-z]+ 차')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('He runs 5 miles', '[0-9]+ 마일')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('There are 3 cats', '[0-9]+ 고양이')) = TRUE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('There are many dogs', '[0-9]+ 개')) = FALSE, 'kor_search_regex test failed';
ASSERT (SELECT kor_search_regex('The book has 200 pages', '[0-9]+ 페이지')) = TRUE, 'kor_search_regex test failed';