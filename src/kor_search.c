#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/guc.h"
#include "catalog/pg_type.h"
#include "executor/spi.h"
#include "commands/trigger.h"
#include <math.h>
#include <string.h>
#include <ctype.h>
#include <regex.h>  // 정규식 관련 함수들을 사용하기 위한 헤더 파일

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

PG_FUNCTION_INFO_V1(kor_search_like);
PG_FUNCTION_INFO_V1(kor_search_similar);
PG_FUNCTION_INFO_V1(kor_search_tsvector);
PG_FUNCTION_INFO_V1(kor_search_regex);

#define MAX_WORDS 1024
#define MAX_WORD_LENGTH 128

// 불용어 리스트 정의
const char *stopwords_korean[] = {"는", "은", "이", "가", "을", "를", "에", "에서", "와", "과", "도", "의", NULL};
const char *stopwords_english[] = {"am", "is", "are", "was", "were", "be", "been", "being", NULL};

// 함수 선언
static bool similar_search_words(const char *token, char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH], int *similar_count);

// 단어를 공백으로 토큰화하고 불용어를 처리
static void tokenize_text(const char *input, char tokens[MAX_WORDS][MAX_WORD_LENGTH], int *token_count, const char **stopwords) {
    char *token;
    char input_copy[1024];
    strncpy(input_copy, input, sizeof(input_copy));
    input_copy[sizeof(input_copy) - 1] = '\0'; // Ensure null termination
    token = strtok(input_copy, " ");
    *token_count = 0;

    while (token != NULL && *token_count < MAX_WORDS) {
        bool is_stopword = false;
        bool is_keyword_in_dict = false;

        // 단어집에서 유사 단어를 찾으며, 해당 단어가 단어집에 있는지 확인
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count = 0;
        is_keyword_in_dict = similar_search_words(token, similar_tokens, &similar_count);

        // 불용어 처리 (단어집에 없을 때만 불용어로 처리)
        if (!is_keyword_in_dict) {
            if (!isalpha(token[0])) {
                size_t token_len = strlen(token);
                for (int i = 0; stopwords[i] != NULL; i++) {
                    size_t stopword_len = strlen(stopwords[i]);
                    if (token_len > stopword_len && strcmp(token + token_len - stopword_len, stopwords[i]) == 0) {
                        token[token_len - stopword_len] = '\0';
                        break;
                    }
                }
            } else {
                for (int i = 0; stopwords[i] != NULL; i++) {
                    if (strcmp(token, stopwords[i]) == 0) {
                        is_stopword = true;
                        break;
                    }
                }
            }
        }

        // 불용어가 아니라면 토큰을 추가
        if (!is_stopword || is_keyword_in_dict) {
            strncpy(tokens[*token_count], token, MAX_WORD_LENGTH);
            tokens[*token_count][MAX_WORD_LENGTH - 1] = '\0'; // Ensure null termination
            (*token_count)++;
        }

        token = strtok(NULL, " ");
    }
}

void to_lowercase(char *str) {
    for (; *str; ++str) {
        *str = tolower(*str);
    }
}

Datum
kor_search_like(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);

    char *input = text_to_cstring(input_text);
    char *search = text_to_cstring(search_text);

    // 입력 텍스트와 검색어를 소문자로 변환
    to_lowercase(input);
    to_lowercase(search);

    // 1. 검색어 자체가 입력 텍스트에 포함되어 있는지 확인
    if (strstr(input, search) != NULL) {
        PG_RETURN_BOOL(true);
    }

    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;

    // 검색어를 토큰화
    tokenize_text(search, tokens_search, &token_count_search, isalpha(search[0]) ? stopwords_english : stopwords_korean);

    // 각 토큰에 대해 단어집에서 유사 단어 검색 후, 입력 텍스트와 비교
    for (int i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;

        // 유사 단어 찾기
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        bool token_found = false;

        // 유사 단어가 입력 텍스트에 포함되어 있는지 확인
        for (int k = 0; k < similar_count; k++) {
            // 유사 단어를 소문자로 변환 후 비교
            to_lowercase(similar_tokens[k]);
            if (strstr(input, similar_tokens[k]) != NULL) {
                token_found = true;
                break;
            }
        }

        if (!token_found) {
            PG_RETURN_BOOL(false);
        }
    }

    PG_RETURN_BOOL(true);
}

static bool similar_search_words(const char *token, char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH], int *similar_count) {
    char query[8192];
    int ret, proc;
    bool is_in_dictionary = false;

    // 단어집에서 유사한 단어와 동의어를 검색하고 자기 자신을 포함하는 쿼리
    snprintf(query, sizeof(query),
             "SELECT DISTINCT k.keyword, s.synonym FROM kor_search_word_transform k "
             "JOIN kor_search_word_synonyms s ON k.id = s.keyword_id "
             "WHERE k.keyword = '%s' OR s.synonym = '%s'",
             token, token);

    SPI_connect();
    ret = SPI_execute(query, true, 0);
    proc = SPI_processed;

    *similar_count = 0;
    if (ret > 0 && SPI_tuptable != NULL) {
        is_in_dictionary = (proc > 0); // 단어가 단어집에 존재하는지 확인
        for (uint64 i = 0; i < proc; i++) {
            char *keyword = SPI_getvalue(SPI_tuptable->vals[i], SPI_tuptable->tupdesc, 1);
            char *synonym = SPI_getvalue(SPI_tuptable->vals[i], SPI_tuptable->tupdesc, 2);

            // keyword 추가
            strncpy(similar_tokens[*similar_count], keyword, MAX_WORD_LENGTH);
            similar_tokens[*similar_count][MAX_WORD_LENGTH - 1] = '\0';
            (*similar_count)++;

            // synonym 추가
            strncpy(similar_tokens[*similar_count], synonym, MAX_WORD_LENGTH);
            similar_tokens[*similar_count][MAX_WORD_LENGTH - 1] = '\0';
            (*similar_count)++;
        }
    }

    SPI_finish();

    return is_in_dictionary;
}

// 유사성 기반 검색 (비교 텍스트의 토큰이 입력 텍스트에 유사하게 포함되는지 검사)
Datum
kor_search_similar(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    bool result = false;

    char *input = text_to_cstring(input_text);
    char *search = text_to_cstring(search_text);

    char tokens_input[MAX_WORDS][MAX_WORD_LENGTH];
    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_input, token_count_search;

    // 불용어를 제거하고 텍스트를 토큰화
    tokenize_text(input, tokens_input, &token_count_input, isalpha(input[0]) ? stopwords_english : stopwords_korean);
    tokenize_text(search, tokens_search, &token_count_search, isalpha(search[0]) ? stopwords_english : stopwords_korean);

    bool all_tokens_similar = true;

    // 검색 텍스트의 각 토큰에 대해 유사 단어 검색
    for (int i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        bool token_similar = false;

        // 유사 단어를 입력 텍스트의 각 토큰과 비교
        for (int k = 0; k < similar_count; k++) {
            for (int j = 0; j < token_count_input; j++) {
                if (strcmp(tokens_input[j], similar_tokens[k]) == 0) {
                    token_similar = true;
                    break;
                }
            }
            if (token_similar) break;
        }

        if (!token_similar) {
            all_tokens_similar = false;
            break;
        }
    }

    result = all_tokens_similar;

    PG_RETURN_BOOL(result);
}

// TSVECTOR 검색 함수
Datum
kor_search_tsvector(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    bool result = false;

    char *input = text_to_cstring(input_text);
    char *search = text_to_cstring(search_text);

    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;
    char tsquery[8192] = "";
    char query[8192];

    // 불용어를 제거하고 텍스트를 토큰화
    tokenize_text(search, tokens_search, &token_count_search, isalpha(search[0]) ? stopwords_english : stopwords_korean);

    for (int i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        for (int k = 0; k < similar_count; k++) {
            if (strlen(tsquery) > 0) {
                strncat(tsquery, " & ", sizeof(tsquery) - strlen(tsquery) - 1);
            }
            strncat(tsquery, similar_tokens[k], sizeof(tsquery) - strlen(tsquery) - 1);
        }
    }

    // tsquery가 비어있으면 false 반환
    if (strlen(tsquery) == 0) {
        PG_RETURN_BOOL(false);
    }

    // TSVECTOR 쿼리 생성
    snprintf(query, sizeof(query),
             "SELECT to_tsvector('english', '%s') @@ to_tsquery('english', '%s');",
             input, tsquery);

    // 쿼리 실행
    SPI_connect();
    int ret = SPI_execute(query, true, 0);
    if (ret > 0 && SPI_processed > 0) {
        bool tsvector_result = (strcmp(SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1), "t") == 0);
        result = tsvector_result;
    }
    SPI_finish();

    PG_RETURN_BOOL(result);
}

// 정규식 검색 함수
Datum
kor_search_regex(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *pattern = PG_GETARG_TEXT_PP(1);
    bool result = false;

    char expanded_pattern[8192] = "";
    char *input = text_to_cstring(input_text);
    char *regex_pattern = text_to_cstring(pattern);
    regex_t regex;

    // 패턴을 토큰화하여 단어집을 적용
    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;

    tokenize_text(regex_pattern, tokens_search, &token_count_search, isalpha(regex_pattern[0]) ? stopwords_english : stopwords_korean);

    for (int i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        for (int k = 0; k < similar_count; k++) {
            if (strlen(expanded_pattern) > 0) {
                strncat(expanded_pattern, ".*", sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
            }
            strncat(expanded_pattern, similar_tokens[k], sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
        }
    }

    // 확장된 패턴이 없으면 원래 패턴 사용
    if (strlen(expanded_pattern) == 0) {
        strncpy(expanded_pattern, regex_pattern, sizeof(expanded_pattern) - 1);
    }

    int ret = regcomp(&regex, expanded_pattern, REG_EXTENDED | REG_NOSUB);
    if (ret) {
        elog(ERROR, "Could not compile regex: %s", expanded_pattern);
    }

    // 정규식 매칭 검사
    if (regexec(&regex, input, 0, NULL, 0) == 0) {
        result = true;
    }

    regfree(&regex);
    PG_RETURN_BOOL(result);
}
