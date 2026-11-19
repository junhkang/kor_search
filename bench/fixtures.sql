CREATE TEMP TABLE evaluation_documents (id int PRIMARY KEY, body text NOT NULL);
INSERT INTO evaluation_documents VALUES
    (1, '삼성에서 PostgreSQL을 사용한다'),
    (2, 'Samsung announced a new device'),
    (3, '삼성동에서 모임을 열었다'),
    (4, '서울에서 인프라 회의를 열었다'),
    (5, 'Seoul hosts an infrastructure conference'),
    (6, '서울대 입학 소식을 알렸다'),
    (7, '철근콘크리트 구조를 설계했다'),
    (8, 'The reinforced concrete structure is ready'),
    (9, 'The concrete needs to be reinforced'),
    (10, 'RC 구조를 설계했다'),
    (11, 'The data science team met'),
    (12, '데이터 과학을 공부한다'),
    (13, 'Data from the science laboratory was dropped'),
    (14, '애플이 새 기기를 발표했다'),
    (15, '과일 가게에서 사과를 샀다'),
    (16, '토마토를 샀다'),
    (17, 'The HanriverDB prototype is ready'),
    (18, '관악구에서 모임을 열었다'),
    (19, 'Samsung PostgreSQL extension notes'),
    (20, '연구팀이 철근 콘크리트에서 균열을 발견했다'),
    (21, '데이터와 과학 정책을 분석했다'),
    (22, '서울역에서 기차를 탔다'),
    (23, '목요일에 부산을 방문했다'),
    (24, 'The apple is in the basket');

CREATE TEMP TABLE evaluation_queries (
    id int PRIMARY KEY, scope text, q text,
    expected int[], baseline tsquery
);
-- PostgreSQL-only baseline: same domain aliases/phrases with Korean prefix matching.
INSERT INTO evaluation_queries VALUES
    (1, 'general', 'samsung', ARRAY[1,2,19], 'samsung | 삼성:*'),
    (2, 'general', '삼성', ARRAY[1,2,19], 'samsung | 삼성:*'),
    (3, 'general', 'samsung postgresql', ARRAY[1,19], '(samsung | 삼성:*) & postgresql:*'),
    (4, 'general', 'seoul', ARRAY[4,5], 'seoul | 서울:*'),
    (5, 'general', '서울', ARRAY[4,5], 'seoul | 서울:*'),
    (6, 'construction', 'RC', ARRAY[7,8,10,20], 'rc | (reinforced <-> concrete) | 철근콘크리트:* | (철근:* <-> 콘크리트:*)'),
    (7, 'construction', 'reinforced concrete', ARRAY[7,8,10,20], 'rc | (reinforced <-> concrete) | 철근콘크리트:* | (철근:* <-> 콘크리트:*)'),
    (8, 'construction', '철근 콘크리트', ARRAY[7,8,10,20], 'rc | (reinforced <-> concrete) | 철근콘크리트:* | (철근:* <-> 콘크리트:*)'),
    (9, 'general', 'data science', ARRAY[11,12,21], '(data <-> science) | (데이터:* <-> 과학:*)'),
    (10, 'general', '데이터 과학', ARRAY[11,12,21], '(data <-> science) | (데이터:* <-> 과학:*)'),
    (11, 'technology', 'apple', ARRAY[14,24], 'apple | 애플:*'),
    (12, 'retail', 'apple', ARRAY[15,24], 'apple | 사과:*'),
    (13, 'general', 'hanriverdb', ARRAY[17], 'hanriverdb'),
    (14, 'general', '부산', ARRAY[23], '부산:*'),
    (15, 'general', 'noresults', ARRAY[]::int[], 'noresults');
