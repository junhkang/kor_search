#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/guc.h"
#include "catalog/pg_type.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

PG_FUNCTION_INFO_V1(kor_like_search);
PG_FUNCTION_INFO_V1(kor_search_tsvector);
PG_FUNCTION_INFO_V1(kor_regex_search);

Datum
kor_search_like(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    bool result = false;

    // TO-DO
    result = true;

    PG_RETURN_BOOL(result);
}

// tsvector 검색 함수
Datum
kor_search_tsvector(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    bool result = false;

    //  TO-DO
    result = true;

    PG_RETURN_BOOL(result);
}

// 정규식 검색 함수
Datum
kor_search_regex(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *pattern = PG_GETARG_TEXT_PP(1);
    bool result = false;

    //  TO-DO
    result = true;

    PG_RETURN_BOOL(result);
}
