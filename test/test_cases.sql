-- kor_search_like Tests
DO $$ 
BEGIN
    -- '밥'이라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('나는 밥을 먹었다', '밥')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 1';
END IF;

-- '밥'이 실제로 'rice'와 매핑되므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('I eat rice', '밥')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 2';
END IF;

    -- '서울'이라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('서울은 한국의 수도이다', '서울')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 3';
END IF;

    -- 'Microsoft'라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('I work at Microsoft', 'Microsoft')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 4';
END IF;

    -- 'Microsoft'라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('나는 마이크로소프트에 취업했어', 'Microsoft')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 5';
END IF;

    -- 'Samsung'이라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('나는 삼성에서 일해', 'Samsung')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 6';
END IF;

    -- '서울'이라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('He lives in Seoul', '서울')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 7';
END IF;

    -- '서울'이라는 단어가 문장에 포함되어 있지 않으므로 FALSE를 기대함
    IF (SELECT kor_search_like('He lives in New York', '서울')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 8';
END IF;

    -- '사과'라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('I like apples', '사과')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 9';
END IF;

    -- 'Harvard'라는 단어가 문장에 포함되어 있으므로 TRUE를 기대함
    IF NOT (SELECT kor_search_like('He studies at Harvard', 'Harvard')) THEN
        RAISE EXCEPTION 'kor_search_like test failed for case 10';
END IF;
END $$;

-- kor_search_similar Tests
DO $$ BEGIN
    -- '밥 먹다'와 'I eat rice'가 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('I eat rice', '밥 먹다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 1';
END IF;

    -- '학교'와 'I go to school'이 의미적으로 유사하지 않으므로 FALSE를 기대함
    IF NOT (SELECT kor_search_similar('I go to school', '학교')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 2';
END IF;

    -- '점심 먹다'와 'He eats lunch'가 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('I eat lunch', '점심 먹다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 3';
END IF;

    -- '책 읽다'와 'She reads a book'이 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('I read a book', '책 읽다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 4';
END IF;

    IF NOT (SELECT kor_search_similar('The car is fast', '차')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 5';
END IF;

    -- '대학 공부하다'와 'He is studying at university'가 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('He is studying at university', '대학 공부하다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 6';
END IF;

    -- '서울 살다'와 'She lives in Seoul'이 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('She lives in Seoul', '서울 살다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 7';
END IF;

    -- '기차 여행하다'와 'He travels by train'이 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('He travels by train', '기차 여행하다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 8';
END IF;

    -- '사과 먹다'와 'He eats an apple'이 의미적으로 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_similar('He eats an apple', '사과 먹다')) THEN
        RAISE EXCEPTION 'kor_search_similar test failed for case 9';
END IF;
END $$;

-- kor_search_tsvector Tests
DO $$ BEGIN
    -- '밥 먹다'라는 검색어가 'I eat rice'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('I eat rice', '밥 먹다')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 1';
END IF;

    -- '학교'라는 검색어가 'I go to school'의 텍스트와 유사함으로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('I go to school', '학교')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 2';
END IF;

    -- '책 읽다'라는 검색어가 'He reads books'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('He reads books', '책 읽다')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 3';
END IF;

    -- '차'라는 검색어가 'The car is fast'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('The car is fast', '차')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 4';
END IF;

    -- '축구하다'라는 검색어가 'They are playing football'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('They are playing football', '축구하다')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 5';
END IF;

    -- '오렌지 먹다'라는 검색어가 'He eats an orange'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('He eats an orange', '오렌지를 먹다')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 6';
END IF;

    -- '달'라는 검색어가 'The moon is bright'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('The moon is bright', '달')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 7';
END IF;

    -- '컴퓨터'라는 검색어가 'The computer is fast'의 텍스트와 유사하므로 TRUE를 기대함
    IF NOT (SELECT kor_search_tsvector('The computer is fast', '컴퓨터')) THEN
        RAISE EXCEPTION 'kor_search_tsvector test failed for case 8';
END IF;
END $$;

-- -- kor_search_regex Tests
-- DO $$ BEGIN
--     -- 'I have 2 apples'에서 '[0-9]+ 사과'라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('I have 2 apples', '[0-9]+ 사과')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 1';
-- END IF;
--
--     -- 'There are no apples'에서 '[0-9]+ 사과'라는 패턴이 매칭되지 않으므로 FALSE를 기대함
--     IF (SELECT kor_search_regex('There are no apples', '[0-9]+ 사과')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 2';
-- END IF;
--
--     -- 'My phone number is 1234'에서 '[0-9]+ 전화번호'라는 패턴이 매칭되지 않으므로 FALSE를 기대함
--     IF (SELECT kor_search_regex('My phone number is 1234', '[0-9]+ 전화번호')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 3';
-- END IF;
--
--     -- 'There are 10 oranges'에서 '[0-9]+ 오렌지'라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('There are 10 oranges', '[0-9]+ 오렌지')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 4';
-- END IF;
--
--     -- 'I have no fruits'에서 '[0-9]+ 과일'이라는 패턴이 매칭되지 않으므로 FALSE를 기대함
--     IF (SELECT kor_search_regex('I have no fruits', '[0-9]+ 과일')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 5';
-- END IF;
--
--     -- 'The car is red'에서 '[a-z]+ 차'라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('The car is red', '[a-z]+ 차')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 6';
-- END IF;
--
--     -- 'He runs 5 miles'에서 '[0-9]+ 마일'이라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('He runs 5 miles', '[0-9]+ 마일')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 7';
-- END IF;
--
--     -- 'There are 3 cats'에서 '[0-9]+ 고양이'라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('There are 3 cats', '[0-9]+ 고양이')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 8';
-- END IF;
--
--     -- 'There are many dogs'에서 '[0-9]+ 개'라는 패턴이 매칭되지 않으므로 FALSE를 기대함
--     IF (SELECT kor_search_regex('There are many dogs', '[0-9]+ 개')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 9';
-- END IF;
--
--     -- 'The book has 200 pages'에서 '[0-9]+ 페이지'라는 패턴이 매칭되므로 TRUE를 기대함
--     IF NOT (SELECT kor_search_regex('The book has 200 pages', '[0-9]+ 페이지')) THEN
--         RAISE EXCEPTION 'kor_search_regex test failed for case 10';
-- END IF;
END $$;
