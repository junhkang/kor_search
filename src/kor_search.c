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
const char *stopwords_korean[] = {"는", "은", "이", "가", "을", "를", "에", "에서", "와", "과", "도", "의", "하다", NULL};
const char *stopwords_english[] = {"am", "is", "are", "was", "were", "be", "been", "being", NULL};

// 함수 선언
static bool similar_search_words(const char *token, char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH], int *similar_count);
static void to_lowercase(char *str);

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
            if (!isalpha((unsigned char)token[0])) {
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

static void to_lowercase(char *str) {
    for (; *str; ++str) {
        *str = tolower((unsigned char)*str);
    }
}

Datum
kor_search_like(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    char *input;
    char *search;
    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;
    int i, k;
    bool token_found;

    input = text_to_cstring(input_text);
    search = text_to_cstring(search_text);

    // 입력 텍스트와 검색어를 소문자로 변환
    to_lowercase(input);
    to_lowercase(search);

    // 1. 검색어 자체가 입력 텍스트에 포함되어 있는지 확인
    if (strstr(input, search) != NULL) {
        PG_RETURN_BOOL(true);
    }

    // 검색어를 토큰화
    tokenize_text(search, tokens_search, &token_count_search, isalpha((unsigned char)search[0]) ? stopwords_english : stopwords_korean);

    // 각 토큰에 대해 단어집에서 유사 단어 검색 후, 입력 텍스트와 비교
    for (i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;

        // 유사 단어 찾기
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        token_found = false;

        // 유사 단어가 입력 텍스트에 포함되어 있는지 확인
        for (k = 0; k < similar_count; k++) {
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
    uint64 i;
    bool is_in_dictionary = false;

    // 단어집에서 유사한 단어와 동의어를 검색하고 자기 자신을 포함하는 쿼리
    snprintf(query, sizeof(query),
             "SELECT DISTINCT k.keyword, s.synonym FROM kor_search_word_transform k "
             "JOIN kor_search_word_synonyms s ON k.id = s.keyword_id "
             "WHERE k.keyword = '%s' OR s.synonym = '%s'",
             token, token);

    // 쿼리 실행 전에 선언과 함께 사용
    SPI_connect();
    ret = SPI_execute(query, true, 0);
    proc = SPI_processed;

    *similar_count = 0;
    if (ret > 0 && SPI_tuptable != NULL) {
        is_in_dictionary = (proc > 0); // 단어가 단어집에 존재하는지 확인
        for (i = 0; i < proc; i++) {
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

Datum
kor_search_similar(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *search_text = PG_GETARG_TEXT_PP(1);
    char *input;
    char *search;
    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;
    int i, k;
    bool result = true;

    input = text_to_cstring(input_text);
    search = text_to_cstring(search_text);

    // 입력 텍스트를 소문자로 변환
    to_lowercase(input);

    // 검색 텍스트(검색 문장)를 토큰화
    tokenize_text(search, tokens_search, &token_count_search, isalpha((unsigned char)search[0]) ? stopwords_english : stopwords_korean);

    // 검색 텍스트(검색 단어)의 각 토큰에 대해 유사 단어 검색
    for (i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count = 0;
        bool token_found = false;

        // 유사 단어 검색
        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        // 유사 단어 중 하나라도 입력 텍스트에 포함되어 있는지 확인
        for (k = 0; k < similar_count; k++) {
            // 유사 단어를 소문자로 변환 후 비교
            to_lowercase(similar_tokens[k]);
            if (strstr(input, similar_tokens[k]) != NULL) {
                token_found = true;
                break;
            }
        }

        // 하나라도 매칭되지 않으면 false 반환
        if (!token_found) {
            result = false;
            break;
        }
    }

    PG_RETURN_BOOL(result);
}

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
    int i, k;
    int ret; // 변수 선언을 함수 시작 부분으로 이동
    char token_group[8192] = ""; // 변수 선언을 함수 시작 부분으로 이동

    // 불용어를 제거하고 텍스트를 토큰화
    tokenize_text(search, tokens_search, &token_count_search, isalpha((unsigned char)search[0]) ? stopwords_english : stopwords_korean);

    for (i = 0; i < token_count_search; i++) {
        char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
        int similar_count;

        similar_search_words(tokens_search[i], similar_tokens, &similar_count);

        // 유사 단어들을 "token1 | token2 | ..." 형태로 결합
        for (k = 0; k < similar_count; k++) {
            if (strlen(token_group) > 0) {
                strncat(token_group, " | ", sizeof(token_group) - strlen(token_group) - 1);
            }
            strncat(token_group, similar_tokens[k], sizeof(token_group) - strlen(token_group) - 1);
        }

        // 여러 유사 단어 그룹을 "&" 연산자로 연결
        if (strlen(tsquery) > 0) {
            strncat(tsquery, " & ", sizeof(tsquery) - strlen(tsquery) - 1);
        }
        strncat(tsquery, token_group, sizeof(tsquery) - strlen(tsquery) - 1);
    }

    if (strlen(tsquery) == 0) {
        PG_RETURN_BOOL(false);
    }

    snprintf(query, sizeof(query),
             "SELECT (to_tsvector('english', '%s') || to_tsvector('simple', '%s')) @@ to_tsquery('simple', '%s');",
             input, input, tsquery);

    // 쿼리 실행
    SPI_connect();
    ret = SPI_execute(query, true, 0); // 이 줄도 필요한 부분으로 이동
    if (ret > 0 && SPI_processed > 0) {
        bool tsvector_result = (strcmp(SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1), "t") == 0);
        result = tsvector_result;
    }
    SPI_finish();

    PG_RETURN_BOOL(result);
}


Datum
kor_search_regex(PG_FUNCTION_ARGS)
{
    text *input_text = PG_GETARG_TEXT_PP(0);
    text *pattern = PG_GETARG_TEXT_PP(1);
    char *input;
    char *regex_pattern;
    char expanded_pattern[8192] = "";
    regex_t regex;
    int i, k;
    bool result = false;

    // 추가된 변수 선언
    char tokens_search[MAX_WORDS][MAX_WORD_LENGTH];
    int token_count_search;
    int ret;

    input = text_to_cstring(input_text);
    regex_pattern = text_to_cstring(pattern);

    // 알파벳이나 한글이 아닌 패턴은 그대로 확장된 패턴에 추가
    if (!isalpha((unsigned char)regex_pattern[0]) && (unsigned char)regex_pattern[0] < 128) {
        strncpy(expanded_pattern, regex_pattern, sizeof(expanded_pattern) - 1);
    } else {
        tokenize_text(regex_pattern, tokens_search, &token_count_search,
                      isalpha((unsigned char)regex_pattern[0]) ? stopwords_english : stopwords_korean);

        for (i = 0; i < token_count_search; i++) {
            char similar_tokens[MAX_WORDS][MAX_WORD_LENGTH];
            int similar_count;
            similar_search_words(tokens_search[i], similar_tokens, &similar_count);

            // 단어가 변환된 경우 정규식 패턴에 포함
            if (similar_count > 0) {
                strncat(expanded_pattern, "(", sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
                for (k = 0; k < similar_count; k++) {
                    if (k > 0) {
                        strncat(expanded_pattern, "|", sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
                    }
                    strncat(expanded_pattern, similar_tokens[k], sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
                }
                strncat(expanded_pattern, ")", sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
            } else {
                // 변환되지 않은 경우 원래 토큰 사용
                if (strlen(expanded_pattern) > 0) {
                    strncat(expanded_pattern, ".*", sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
                }
                strncat(expanded_pattern, tokens_search[i], sizeof(expanded_pattern) - strlen(expanded_pattern) - 1);
            }
        }
    }

    // 확장된 패턴이 없으면 원래 패턴 사용
    if (strlen(expanded_pattern) == 0) {
        strncpy(expanded_pattern, regex_pattern, sizeof(expanded_pattern) - 1);
    }

    // 정규식 컴파일 및 매칭 검사
    ret = regcomp(&regex, expanded_pattern, REG_EXTENDED | REG_NOSUB);
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