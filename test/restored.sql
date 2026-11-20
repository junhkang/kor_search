SET search_path TO pg_catalog;
DO $$ BEGIN
    IF (SELECT extversion FROM pg_extension WHERE extname = 'kor_search') <> '2.0.0'
        OR NOT "search utils".kor_search_like('도급업체를 선정했다', 'contractor')
        OR NOT ("search utils".kor_vector_v1('도급업체를 선정했다')
                @@ "search utils".kor_search_tsquery('contractor', 'example')) THEN
        RAISE EXCEPTION 'custom schema, legacy data or 2.0 aliases were lost';
    END IF;
END $$;
