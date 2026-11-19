#include "postgres.h"

#include "fmgr.h"
#include "lib/stringinfo.h"
#include "mb/pg_wchar.h"
#include "utils/builtins.h"
#include "utils/fmgrprotos.h"
#include "varatt.h"

#define MAX_DOCUMENT_BYTES (512 * 1024)

extern ptrdiff_t kor_native_analyze(const char *input, size_t len, char *output, size_t capacity);

PG_FUNCTION_INFO_V1(kor_analyze_v1);
PG_FUNCTION_INFO_V1(kor_vector_v1);

static char *
analyze_document(text *input, size_t *len)
{
    size_t input_len = VARSIZE_ANY_EXHDR(input);
    size_t capacity = input_len;
    char *output;
    ptrdiff_t used;

    if (GetDatabaseEncoding() != PG_UTF8)
        ereport(ERROR, (errcode(ERRCODE_FEATURE_NOT_SUPPORTED), errmsg("kor_search requires a UTF-8 database")));
    if (input_len > MAX_DOCUMENT_BYTES)
        ereport(ERROR, (errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED), errmsg("kor_search input exceeds 512 KiB")));

    output = palloc(capacity + 1);
    used = kor_native_analyze(VARDATA_ANY(input), input_len, output, capacity);
    if (used >= 0 && (size_t) used > capacity)
    {
        capacity = used;
        output = repalloc(output, capacity + 1);
        used = kor_native_analyze(VARDATA_ANY(input), input_len, output, capacity);
    }
    if (used < 0 || (size_t) used > capacity)
        ereport(ERROR, (errcode(ERRCODE_DATA_EXCEPTION), errmsg("kor_search could not analyze the input"),
                        errhint("Check document and individual token lengths.")));
    output[used] = '\0';
    *len = used;
    return output;
}

Datum
kor_analyze_v1(PG_FUNCTION_ARGS)
{
    size_t len;
    char *analyzed = analyze_document(PG_GETARG_TEXT_PP(0), &len);

    PG_RETURN_TEXT_P(cstring_to_text_with_len(analyzed, len));
}

Datum
kor_vector_v1(PG_FUNCTION_ARGS)
{
    size_t len;
    char *analyzed = analyze_document(PG_GETARG_TEXT_PP(0), &len);
    StringInfoData raw;
    char *state;
    int pos = 0;

    initStringInfo(&raw);
    /* Rust emits only word characters, separated by ASCII spaces. */
    for (char *token = strtok_r(analyzed, " ", &state); token; token = strtok_r(NULL, " ", &state))
        appendStringInfo(&raw, "%s:%d ", token, ++pos);
    return DirectFunctionCall1(tsvectorin, CStringGetDatum(raw.data));
}
