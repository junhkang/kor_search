#include "postgres.h"

#include "catalog/namespace.h"
#include "catalog/pg_type.h"
#include "executor/spi.h"
#include "fmgr.h"
#include "lib/stringinfo.h"
#include "nodes/makefuncs.h"
#include "tsearch/ts_type.h"
#include "utils/builtins.h"
#include "utils/fmgrprotos.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(kor_search_like);
PG_FUNCTION_INFO_V1(kor_search_similar);
PG_FUNCTION_INFO_V1(kor_search_tsvector);
PG_FUNCTION_INFO_V1(kor_search_regex);

#define MAX_LEGACY_ALIASES 512
#define LEGACY_WHITESPACE " \t\r\n\f\v"
#define REGEX_META "\\.^$|?*+()[]{}"

static void
ascii_lower(char *str)
{
    for (; *str; str++)
        *str = pg_ascii_tolower((unsigned char) *str);
}

static char *
legacy_lookup_sql(FunctionCallInfo fcinfo)
{
    char *schema = get_namespace_name(get_func_namespace(fcinfo->flinfo->fn_oid));
    char *keywords = quote_qualified_identifier(schema, "kor_search_word_transform");
    char *synonyms = quote_qualified_identifier(schema, "kor_search_word_synonyms");

    return psprintf("SELECT DISTINCT k.keyword, s.synonym FROM %s k "
                    "JOIN %s s ON k.id OPERATOR(pg_catalog.=) s.keyword_id "
                    "WHERE k.keyword OPERATOR(pg_catalog.=) $1 OR s.synonym OPERATOR(pg_catalog.=) $1",
                    keywords, synonyms);
}

static List *
legacy_aliases(SPIPlanPtr plan, char *token)
{
    Datum args[] = {CStringGetTextDatum(token)};
    MemoryContext context = CurrentMemoryContext;
    List *aliases = NIL;
    int status = SPI_execute_plan(plan, args, NULL, true, MAX_LEGACY_ALIASES + 1);

    if (status != SPI_OK_SELECT)
        elog(ERROR, "kor_search dictionary lookup failed");
    if (SPI_processed > MAX_LEGACY_ALIASES)
        ereport(ERROR, (errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
                        errmsg("too many kor_search aliases for one term")));

    MemoryContextSwitchTo(context);
    for (uint64 i = 0; i < SPI_processed; i++)
    {
        HeapTuple tuple = SPI_tuptable->vals[i];
        TupleDesc desc = SPI_tuptable->tupdesc;

        for (int col = 1; col <= 2; col++)
        {
            char *term = SPI_getvalue(tuple, desc, col);

            if (term && *term)
                aliases = lappend(aliases, term);
        }
    }
    SPI_freetuptable(SPI_tuptable);
    return aliases;
}

static bool
legacy_stopword(const char *token)
{
    static const char *words[] = {"am", "is", "are", "was", "were", "be", "been", "being"};

    for (int i = 0; i < lengthof(words); i++)
        if (strcmp(token, words[i]) == 0)
            return true;
    return false;
}

static List *
legacy_expand(SPIPlanPtr plan, const char *token)
{
    static const char *suffixes[] = {"에서", "하다", "는", "은", "이", "가", "을", "를", "에", "와", "과", "도", "의"};
    char *key = pstrdup(token);
    List *aliases;
    size_t len;

    ascii_lower(key);
    aliases = legacy_aliases(plan, key);
    if (aliases != NIL)
        return lcons(key, aliases);
    if (legacy_stopword(key))
        return NIL;

    len = strlen(key);
    for (int i = 0; i < lengthof(suffixes); i++)
    {
        size_t suffix_len = strlen(suffixes[i]);

        if (len > suffix_len && strcmp(key + len - suffix_len, suffixes[i]) == 0)
        {
            char *root = pnstrdup(key, len - suffix_len);

            aliases = legacy_aliases(plan, root);
            if (aliases != NIL)
                aliases = lcons(root, aliases);
            break;
        }
    }
    return lcons(key, aliases);
}

static Datum
simple_phrase(Oid config, const char *term)
{
    return DirectFunctionCall2(phraseto_tsquery_byid, ObjectIdGetDatum(config),
                               CStringGetTextDatum(term));
}

static Datum
combine_query(PGFunction fn, Datum left, Datum right)
{
    if (!left || DatumGetTSQuery(right)->size == 0)
        return (left && DatumGetTSQuery(left)->size > 0) ? left : right;
    if (DatumGetTSQuery(left)->size == 0)
        return right;
    return DirectFunctionCall2(fn, left, right);
}

static void
append_regex_literal(StringInfo pattern, const char *term)
{
    for (; *term; term++)
    {
        if (strchr(REGEX_META, *term))
            appendStringInfoChar(pattern, '\\');
        appendStringInfoChar(pattern, *term);
    }
}

typedef enum { LEGACY_LIKE, LEGACY_SIMILAR, LEGACY_FTS, LEGACY_REGEX } LegacyMode;

static bool
legacy_match(FunctionCallInfo fcinfo, LegacyMode mode)
{
    text *document = PG_GETARG_TEXT_PP(0);
    text *search = PG_GETARG_TEXT_PP(1);
    char *input = text_to_cstring(document);
    char *query = text_to_cstring(search);
    char *saveptr;
    char *lookup;
    SPIPlanPtr plan;
    MemoryContext caller = CurrentMemoryContext;
    StringInfoData regex = {0};
    Datum tsquery = 0;
    Oid simple = InvalidOid;
    Oid english = InvalidOid;
    bool matched = true;
    bool has_terms = false;

    if (mode == LEGACY_REGEX && strpbrk(query, REGEX_META))
        return DatumGetBool(DirectFunctionCall2Coll(textregexeq, PG_GET_COLLATION(),
                                                    PointerGetDatum(document), PointerGetDatum(search)));
    if (mode == LEGACY_LIKE || mode == LEGACY_SIMILAR)
    {
        ascii_lower(input);
        ascii_lower(query);
        if (mode == LEGACY_LIKE && strstr(input, query))
            return true;
    }
    if (mode == LEGACY_REGEX)
        initStringInfo(&regex);
    if (mode == LEGACY_FTS)
    {
        simple = get_ts_config_oid(list_make2(makeString("pg_catalog"), makeString("simple")), false);
        english = get_ts_config_oid(list_make2(makeString("pg_catalog"), makeString("english")), false);
    }

    lookup = legacy_lookup_sql(fcinfo);
    if (SPI_connect() != SPI_OK_CONNECT)
        elog(ERROR, "could not connect to the kor_search dictionary");
    plan = SPI_prepare(lookup, 1, (Oid[]) {TEXTOID});
    if (!plan)
        elog(ERROR, "could not prepare the kor_search dictionary lookup");
    MemoryContextSwitchTo(caller);

    for (char *token = strtok_r(query, LEGACY_WHITESPACE, &saveptr);
         token; token = strtok_r(NULL, LEGACY_WHITESPACE, &saveptr))
    {
        List *aliases = legacy_expand(plan, token);
        ListCell *entry;
        Datum group = 0;
        bool hit = false;
        bool first = true;

        if (aliases == NIL)
            continue;
        if (mode == LEGACY_REGEX)
            appendStringInfoString(&regex, has_terms ? ".*(" : "(");
        has_terms = true;

        foreach(entry, aliases)
        {
            char *term = lfirst(entry);

            if (mode == LEGACY_FTS)
            {
                group = combine_query(tsquery_or, group, simple_phrase(simple, term));
                group = combine_query(tsquery_or, group, simple_phrase(english, term));
            }
            else if (mode == LEGACY_REGEX)
            {
                if (!first)
                    appendStringInfoChar(&regex, '|');
                append_regex_literal(&regex, first ? token : term);
                first = false;
            }
            else
            {
                ascii_lower(term);
                if (strstr(input, term))
                {
                    hit = true;
                    break;
                }
            }
        }
        if (mode == LEGACY_FTS)
            tsquery = combine_query(tsquery_and, tsquery, group);
        else if (mode == LEGACY_REGEX)
            appendStringInfoChar(&regex, ')');
        else if (!hit)
        {
            matched = false;
            break;
        }
    }
    SPI_freeplan(plan);
    SPI_finish();

    if (mode == LEGACY_FTS)
    {
        Datum doc = PointerGetDatum(document);
        Datum vec;

        if (!tsquery || DatumGetTSQuery(tsquery)->size == 0)
            return false;
        vec = DirectFunctionCall2(tsvector_concat,
                                  DirectFunctionCall2(to_tsvector_byid, ObjectIdGetDatum(simple), doc),
                                  DirectFunctionCall2(to_tsvector_byid, ObjectIdGetDatum(english), doc));
        return DatumGetBool(DirectFunctionCall2(ts_match_vq, vec, tsquery));
    }
    if (mode == LEGACY_REGEX)
        return DatumGetBool(DirectFunctionCall2Coll(textregexeq, PG_GET_COLLATION(),
                                                    PointerGetDatum(document),
                                                    has_terms ? CStringGetTextDatum(regex.data) : PointerGetDatum(search)));
    return has_terms && matched;
}

Datum
kor_search_like(PG_FUNCTION_ARGS)
{
    PG_RETURN_BOOL(legacy_match(fcinfo, LEGACY_LIKE));
}

Datum
kor_search_similar(PG_FUNCTION_ARGS)
{
    PG_RETURN_BOOL(legacy_match(fcinfo, LEGACY_SIMILAR));
}

Datum
kor_search_tsvector(PG_FUNCTION_ARGS)
{
    PG_RETURN_BOOL(legacy_match(fcinfo, LEGACY_FTS));
}

Datum
kor_search_regex(PG_FUNCTION_ARGS)
{
    PG_RETURN_BOOL(legacy_match(fcinfo, LEGACY_REGEX));
}
