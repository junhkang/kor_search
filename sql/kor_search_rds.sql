\i kor_search_data.sql
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
-- 키워드 삽입
INSERT INTO kor_search_word_transform (keyword)
VALUES
('lg'), ('samsung'), ('apple'), ('google'), ('microsoft'), ('hyundai'), ('kia'), ('naver'),
('kakao'), ('sk'), ('seoul'), ('busan'), ('java'), ('python'), ('machine'), ('learning'),
('artificial'), ('intelligence'), ('big'), ('data'), ('science'), ('deep'), ('hello'), ('hi'),
('yes'), ('no'), ('thanks'), ('thank'), ('you'), ('welcome'), ('sorry'), ('excuse'), ('me'),
('good'), ('morning'), ('night'), ('evening'), ('afternoon'), ('please'), ('food'), ('eat'),
('drink'), ('water'), ('coffee'), ('tea'), ('rice'), ('bread'), ('meat'), ('fish'), ('vegetable'),
('fruit'), ('car'), ('bus'), ('train'), ('airplane'), ('ship'), ('house'), ('home'), ('school'),
('office'), ('restaurant'), ('store'), ('shop'), ('park'), ('city'), ('country'), ('beautiful'),
('happy'), ('sad'), ('angry'), ('surprised'), ('worried'), ('tired'), ('sleep'), ('run'), ('walk'),
('jump'), ('sit'), ('stand'), ('read'), ('write'), ('listen'), ('speak'), ('talk'), ('buy'),
('sell'), ('work'), ('play'), ('game'), ('sports'), ('music'), ('movie'), ('book'), ('friend'),
('family'), ('child'), ('children'), ('man'), ('woman'), ('boy'), ('girl'), ('brother'), ('sister'),
('father'), ('mother'), ('parent'), ('son'), ('daughter'), ('love'), ('like'), ('dislike'), ('hate'),
('need'), ('want'), ('must'), ('can'), ('could'), ('will'), ('would'), ('should'), ('shall'), ('may'),
('might'), ('and'), ('or'), ('but'), ('because'), ('so'), ('if'), ('then'), ('when'), ('where'), ('who'),
('what'), ('which'), ('how'), ('why'), ('this'), ('that'), ('these'), ('those'), ('my'), ('your'),
('his'), ('her'), ('its'), ('our'), ('their'), ('mine'), ('yours'), ('hers'), ('ours'), ('theirs'),
('one'), ('two'), ('three'), ('four'), ('five'), ('six'), ('seven'), ('eight'), ('nine'), ('ten'), ('lunch'), ('university'),
('study'), ('live'), ('computer'), ('travel'), ('football'), ('moon');

-- 유사어 삽입
INSERT INTO kor_search_word_synonyms (keyword_id, synonym)
VALUES
((SELECT id FROM kor_search_word_transform WHERE keyword = 'lg'), '엘지'),
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
((SELECT id FROM kor_search_word_transform WHERE keyword = 'seoul'), '서울'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'seoul'), '서울특별시'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'busan'), '부산'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'java'), '자바'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'python'), '파이썬'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'machine'), '머신'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'learning'), '학습'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'artificial'), '인공'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'intelligence'), '지능'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'big'), '빅'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'data'), '데이터'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'science'), '과학'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'deep'), '딥'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'hello'), '안녕하세요'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'hi'), '안녕'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'yes'), '네'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'no'), '아니오'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'thanks'), '감사합니다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'thank'), '감사'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'you'), '당신'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'welcome'), '환영합니다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sorry'), '미안합니다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'excuse'), '실례합니다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'me'), '나'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'good'), '좋은'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'morning'), '아침'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'night'), '밤'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'evening'), '저녁'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'afternoon'), '오후'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'please'), '제발'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'food'), '음식'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'eat'), '먹다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'drink'), '마시다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'water'), '물'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'coffee'), '커피'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'tea'), '차'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'rice'), '밥'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'bread'), '빵'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'meat'), '고기'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'fish'), '생선'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'vegetable'), '야채'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'fruit'), '과일'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'car'), '차'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'bus'), '버스'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'train'), '기차'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'airplane'), '비행기'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'ship'), '배'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'house'), '집'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'home'), '가정'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'school'), '학교'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'office'), '사무실'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'restaurant'), '식당'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'store'), '가게'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'shop'), '상점'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'park'), '공원'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'city'), '도시'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'country'), '국가'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'beautiful'), '아름다운'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'happy'), '행복한'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sad'), '슬픈'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'angry'), '화난'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'surprised'), '놀란'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'worried'), '걱정하는'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'tired'), '피곤한'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sleep'), '자다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'run'), '달리다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'walk'), '걷다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'jump'), '뛰다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sit'), '앉다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'stand'), '서다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'read'), '읽다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'write'), '쓰다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'listen'), '듣다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'speak'), '말하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'talk'), '이야기하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'buy'), '사다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sell'), '팔다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'work'), '일하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'play'), '놀다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'game'), '게임'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sports'), '스포츠'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'music'), '음악'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'movie'), '영화'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'book'), '책'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'friend'), '친구'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'family'), '가족'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'child'), '아이'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'children'), '아이들'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'man'), '남자'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'woman'), '여자'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'boy'), '소년'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'girl'), '소녀'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'brother'), '형제'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'sister'), '자매'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'father'), '아버지'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'mother'), '어머니'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'parent'), '부모'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'son'), '아들'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'daughter'), '딸'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'love'), '사랑하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'like'), '좋아하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'dislike'), '싫어하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'hate'), '증오하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'need'), '필요하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'want'), '원하다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'must'), '해야 한다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'can'), '할 수 있다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'can'), '캔'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'could'), '할 수 있었다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'will'), '할 것이다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'would'), '할 것이다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'should'), '해야 한다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'shall'), '할 것이다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'may'), '할 수 있다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'might'), '할 수 있었다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'and'), '그리고'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'or'), '또는'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'but'), '그러나'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'because'), '왜냐하면'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'so'), '그래서'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'if'), '만약'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'then'), '그때'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'when'), '언제'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'where'), '어디서'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'who'), '누구'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'what'), '무엇'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'which'), '어느'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'how'), '어떻게'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'why'), '왜'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'this'), '이것'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'that'), '저것'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'these'), '이것들'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'those'), '저것들'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'my'), '나의'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'your'), '너'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'his'), '그'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'her'), '그녀'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'its'), '그것의'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'our'), '우리'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'one'), '하나'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'two'), '둘'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'three'), '셋'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'four'), '넷'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'five'), '다섯'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'six'), '여섯'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'seven'), '일곱'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'eight'), '여덟'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'nine'), '아홉'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'ten'), '열'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'lunch'), '점심'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'university'), '대학'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'study'), '공부'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'live'), '살다'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'computer'), '컴퓨터'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'travel'), '여행'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'football'), '축구'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'moon'), '달'),
((SELECT id FROM kor_search_word_transform WHERE keyword = 'ate'), '먹다');


CREATE OR REPLACE FUNCTION kor_search_like(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    token text;
    similar_tokens text[];
    token_found boolean := false;
BEGIN
    input_text := lower(input_text);
    search_text := lower(search_text);

    FOR token IN SELECT unnest(string_to_array(search_text, ' ')) LOOP
        SELECT array_agg(DISTINCT k.keyword) || array_agg(DISTINCT s.synonym)
        INTO similar_tokens
        FROM kor_search_word_transform k
        LEFT JOIN kor_search_word_synonyms s ON k.id = s.keyword_id
        WHERE k.keyword = token OR s.synonym = token;

        IF similar_tokens IS NOT NULL THEN
            FOR i IN array_lower(similar_tokens, 1) .. array_upper(similar_tokens, 1) LOOP
                IF position(similar_tokens[i] in input_text) > 0 THEN
                    token_found := true;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF NOT token_found THEN
            RETURN false;
        END IF;
        token_found := false;
    END LOOP;

    RETURN true;
END;
$$ LANGUAGE plpgsql;


-- tsvector 검색 함수
CREATE OR REPLACE FUNCTION kor_search_tsvector(input_text text, search_text text)
RETURNS boolean AS $$
DECLARE
    vec tsvector := to_tsvector('english', input_text);
    tsquery_str text := '';
    token text;
    similar_tokens text[];
BEGIN
    -- 검색어를 공백으로 분리하여 각 토큰에 대해 처리
    FOR token IN SELECT unnest(string_to_array(lower(unaccent(search_text)), ' ')) LOOP
        -- 유사 단어 집합을 가져옴 (양방향 조회)
        SELECT array_agg(DISTINCT k.keyword) || array_agg(DISTINCT s.synonym)
        INTO similar_tokens
        FROM kor_search_word_transform k
        LEFT JOIN kor_search_word_synonyms s ON k.id = s.keyword_id
        WHERE k.keyword = token OR s.synonym = token;

        -- 유사 단어들을 '|' 연산자로 결합하여 tsquery 형태로 생성
        IF similar_tokens IS NOT NULL THEN
            tsquery_str := tsquery_str || '(' || array_to_string(similar_tokens, ' | ') || ') & ';
        ELSE
            -- 유사 단어가 없는 경우 원래의 토큰을 추가
            tsquery_str := tsquery_str || token || ' & ';
        END IF;
    END LOOP;

    -- 마지막 '&'를 제거
    tsquery_str := regexp_replace(tsquery_str, ' & $', '', 'g');

    -- tsquery로 변환 후 vec와 비교하여 매칭 여부 반환
    RETURN to_tsvector('english', input_text) @@ to_tsquery('english', tsquery_str);
END;
$$ LANGUAGE plpgsql;

-- TODO 정규식 검색 함수 생성
CREATE OR REPLACE FUNCTION kor_regex_search(input_text text, pattern text)
RETURNS boolean AS $$
BEGIN
    RETURN input_text ~* pattern;
END;
$$ LANGUAGE plpgsql;


