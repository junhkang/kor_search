-- Run with the kor_search extension schema on search_path.
INSERT INTO kor_search_aliases(scope, concept, term, kind) VALUES
    ('general', 'samsung', 'Samsung', 'label'),
    ('general', 'samsung', '삼성', 'transliteration'),
    ('general', 'seoul', 'Seoul', 'label'),
    ('general', 'seoul', '서울', 'transliteration'),
    ('general', 'data-science', 'data science', 'label'),
    ('general', 'data-science', '데이터 과학', 'translation'),
    ('construction', 'reinforced-concrete', '철근 콘크리트', 'label'),
    ('construction', 'reinforced-concrete', '철근콘크리트', 'synonym'),
    ('construction', 'reinforced-concrete', 'reinforced concrete', 'translation'),
    ('construction', 'reinforced-concrete', 'RC', 'abbreviation'),
    ('retail', 'fruit-apple', 'apple', 'label'),
    ('retail', 'fruit-apple', '사과', 'translation'),
    ('technology', 'brand-apple', 'apple', 'label'),
    ('technology', 'brand-apple', '애플', 'transliteration')
ON CONFLICT (scope, term_key) DO NOTHING;
