CREATE FUNCTION kor_analyze_v1(input text)
RETURNS text AS 'MODULE_PATHNAME', 'kor_analyze_v1'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION kor_vector_v1(input text)
RETURNS tsvector AS 'MODULE_PATHNAME', 'kor_vector_v1'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TABLE kor_search_aliases (
    scope text COLLATE "C" NOT NULL CHECK (octet_length(scope) BETWEEN 1 AND 128),
    concept text COLLATE "C" NOT NULL CHECK (octet_length(concept) BETWEEN 1 AND 128),
    term text NOT NULL CHECK (octet_length(term) BETWEEN 1 AND 512),
    kind text NOT NULL CHECK (kind IN ('label', 'translation', 'transliteration', 'abbreviation', 'synonym')),
    term_key text COLLATE "C" GENERATED ALWAYS AS (@extschema@.kor_analyze_v1(term)) STORED,
    PRIMARY KEY (scope, term_key),
    CHECK (octet_length(term_key) BETWEEN 1 AND 512
        AND cardinality(string_to_array(term_key, ' ')) BETWEEN 1 AND 8)
);

CREATE INDEX kor_search_aliases_concept ON kor_search_aliases (scope, concept, term_key);
SELECT pg_catalog.pg_extension_config_dump('kor_search_aliases', '');

CREATE FUNCTION kor_search_tsquery(input text, dictionary_scope text DEFAULT 'general')
RETURNS tsquery
LANGUAGE plpgsql STABLE STRICT PARALLEL RESTRICTED
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    words text[];
    at_word int := 1;
    word_count int;
    matched_width int;
    match_concept text;
    term_text text;
    expanded text;
    expansions int;
    group_query tsquery;
    result tsquery;
BEGIN
    IF octet_length(input) > 4096 THEN
        RAISE EXCEPTION 'kor_search query exceeds 4 KiB' USING ERRCODE = '54000';
    END IF;
    IF octet_length(dictionary_scope) NOT BETWEEN 1 AND 128 THEN
        RAISE EXCEPTION 'invalid kor_search scope length' USING ERRCODE = '22023';
    END IF;

    words := string_to_array(@extschema@.kor_analyze_v1(input), ' ');
    word_count := cardinality(words);
    IF word_count > 64 THEN
        RAISE EXCEPTION 'kor_search query exceeds 64 tokens' USING ERRCODE = '54000';
    END IF;

    WHILE at_word <= word_count LOOP
        match_concept := NULL;
        matched_width := 1;
        FOR width IN REVERSE least(8, word_count - at_word + 1)..1 LOOP
            term_text := array_to_string(words[at_word:at_word + width - 1], ' ');
            SELECT a.concept INTO match_concept
            FROM @extschema@.kor_search_aliases AS a
            WHERE a.scope = dictionary_scope AND a.term_key = term_text;
            IF FOUND THEN
                matched_width := width;
                EXIT;
            END IF;
        END LOOP;

        IF match_concept IS NULL THEN
            group_query := words[at_word]::tsquery;
        ELSE
            group_query := NULL;
            expansions := 0;
            FOR expanded IN
                SELECT a.term_key FROM @extschema@.kor_search_aliases AS a
                WHERE a.scope = dictionary_scope AND a.concept = match_concept
                ORDER BY a.term_key LIMIT 33
            LOOP
                IF expansions = 32 THEN
                    RAISE EXCEPTION 'kor_search concept exceeds 32 aliases' USING ERRCODE = '54000';
                END IF;
                -- Only analyzer-generated word characters enter the tsquery grammar.
                group_query := coalesce(group_query || replace(expanded, ' ', ' <-> ')::tsquery,
                                        replace(expanded, ' ', ' <-> ')::tsquery);
                expansions := expansions + 1;
            END LOOP;
        END IF;

        result := coalesce(result && group_query, group_query);
        at_word := at_word + matched_width;
    END LOOP;
    RETURN result;
END;
$fn$;

COMMENT ON FUNCTION kor_vector_v1(text) IS 'Versioned Korean/English document analysis for a PostgreSQL GIN expression index';
COMMENT ON FUNCTION kor_search_tsquery(text, text) IS 'Analyze plain text and expand scoped aliases; returns NULL for an empty query';
