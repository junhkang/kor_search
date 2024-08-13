<p align="right">
  <a href="/"><img src="https://upload.wikimedia.org/wikipedia/commons/0/09/Flag_of_South_Korea.svg" width="30"></a>
  <a href="#"><img src="https://upload.wikimedia.org/wikipedia/en/a/a4/Flag_of_the_United_States.svg" width="30"></a>
</p>
# kor_search

Korean text search extension for PostgreSQL.

## Description

`kor_search` is a PostgreSQL extension that provides text search functionality between Korean and English. Developed without reliance on external APIs like translators or morphological analyzers, it is optimized for word-based searches. While it supports sentence-to-sentence searches to some extent, it is primarily designed for word searches. This extension can be used in environments where PostgreSQL is installed, and it also provides functions that can be used in environments where external extensions are restricted, such as RDS.

### Key Features

- **LIKE Search**: Checks if the input text matches or includes the specified search term.
- **tsvector Search**: Converts text to tsvector format to support similar word searches.
- **Regex Search**: Provides regex search functionality for complex search conditions.
- **Similarity Search**: Evaluates sentence similarity based on a dictionary of synonyms.

### Flexible Custom Search

`kor_search` allows you to modify internal table data to provide search tailored to specific industries or fields. For example, in the case of 산업의 역군, the extension has been customized for searches related to construction by applying a large amount of construction-related data.

### Performance Considerations

Performance analysis is essential when querying large amounts of data, as search speed can be affected by the size of the dictionary. While functions similar to the extension are implemented for environments where external extensions are restricted (such as RDS), they may not perform as well as the extension itself.

## Installation

### Environments with PostgreSQL Installed

1. To build and install the PostgreSQL extension, run the following commands:

    ```sh
    make
    sudo make install
    ```

2. Then, connect to your PostgreSQL database and enable the extension:

    ```sh
    psql -U your_username -d your_database
    CREATE EXTENSION kor_search;
    ```

### Environments with Restricted External Extensions (RDS)

1. Connect to your RDS instance. For example, you can use `psql` to connect:

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. Copy the contents of the `kor_search_rds.sql` file directly into the SQL prompt of your RDS instance and execute it. This file contains the SQL code needed to implement the functionality of `kor_search`.

## Functions

### kor_search_similar

- `kor_search_similar(input_text text, search_text text)`: Determines if `input_text` is semantically similar to `search_text`. This function evaluates the similarity between sentences based on a dictionary of synonyms.

#### Usage Example:

1. Sentence Similarity Check:

    ```sql
    -- '밥 먹다' is semantically similar to 'I eat rice', so TRUE is expected
    SELECT kor_search_similar('I eat rice', '밥 먹다');  -- Result: true

    -- '서울 살다' is semantically similar to 'She lives in Seoul', so TRUE is expected
    SELECT kor_search_similar('She lives in Seoul', '서울 살다');  -- Result: true

    -- '차가 빠르다' is semantically similar to 'The car is fast', so TRUE is expected
    SELECT kor_search_similar('The car is fast', '차가 빠르다');  -- Result: true
    ```

### kor_like

- `kor_like(input_text text, search_text text)`: Checks if the synonyms corresponding to `search_text` are included in `input_text` using a LIKE query.

#### Usage Example:

1. Word Inclusion Check:

    ```sql
    -- Search for 'lg' keyword with '엘지', '앨지'
    SELECT kor_like('이것은 엘지 제품입니다', 'lg');  -- Result: true
    SELECT kor_like('이것은 LG 제품입니다', '엘지');  -- Result: true

    -- Search for 'apple' keyword with '애플', '사과'
    SELECT kor_like('애플은 훌륭한 과일입니다', 'apple');  -- Result: true
    SELECT kor_like('사과를 좋아합니다', 'apple');  -- Result: true
    SELECT kor_like('Apple은 과일입니다', '사과');  -- Result: true
    ```

### kor_search_tsvector

- `kor_search_tsvector(input_text text, search_text text)`: Checks if the synonyms corresponding to `search_text` are included in the tsvector of `input_text`.

#### Usage Example:

1. Search for Similar Words Using tsvector:

    ```sql
    -- Search for 'data science' keyword with '데이터 과학', '데이터 사이언스'
    SELECT kor_search_tsvector('데이터 과학은 미래의 유망한 분야입니다', 'data science');  -- Result: true
    SELECT kor_search_tsvector('데이터 사이언스는 많은 가능성을 제공합니다', 'data science');  -- Result: true
    SELECT kor_search_tsvector('Data Science는 많은 가능성을 제공합니다', '데이터 과학');  -- Result: true

    -- Search for 'machine learning' keyword with '머신러닝', '기계학습'
    SELECT kor_search_tsvector('머신러닝 기술이 발전하고 있습니다', 'machine learning');  -- Result: true
    SELECT kor_search_tsvector('기계학습 알고리즘을 연구합니다', 'machine learning');  -- Result: true
    SELECT kor_search_tsvector('Machine Learning 알고리즘을 연구합니다', '기계학습');  -- Result: true
    ```

### kor_regex_search

- `kor_regex_search(input_text text, pattern text)`: Checks if a regex pattern matches the `input_text`.

#### Usage Example:

1. Regex Search:

    ```sql
    -- Search for specific word patterns using regex
    SELECT kor_regex_search('자바는 강력한 언어입니다', '자바|파이썬');  -- Result: true
    SELECT kor_regex_search('파이썬은 배우기 쉬운 언어입니다', '자바|파이썬');  -- Result: true
    SELECT kor_regex_search('JAVA와 PYTHON은 인기있는 언어입니다', '(?i)자바|파이썬');  -- Result: true

    -- Search for 'big data' and '대용량 데이터' using regex
    SELECT kor_regex_search('빅데이터 분석이 중요합니다', '빅데이터|대용량 데이터');  -- Result: true
    SELECT kor_regex_search('대용량 데이터를 처리합니다', '빅데이터|대용량 데이터');  -- Result: true
    SELECT kor_regex_search('Big Data는 현대 기술의 핵심입니다', '(?i)빅데이터|대용량 데이터');  -- Result: true
    ```

## Managing the Word Conversion Table

You can add new keywords and synonyms to the word conversion table. This allows for implementing custom searches tailored to specific industries or business needs. For example, to add a synonym for the 'apple' keyword, do the following:

```sql
INSERT INTO kor_search_word_transform (keyword)
VALUES ('apple');

INSERT INTO kor_search_word_synonyms (keyword_id, synonym)
VALUES ((SELECT id FROM kor_search_word_transform WHERE keyword = 'apple'), '애플');
```

## Uninstallation

### Environments with PostgreSQL Installed

To uninstall the extension from an environment where PostgreSQL is installed, follow these steps:

1. Connect to your PostgreSQL database.

    ```sh
    psql -U your_username -d your_database
    ```

2. Drop the extension.

    ```sql
    DROP EXTENSION kor_search;
    ```

### Environments with Restricted External Extensions (RDS)

To uninstall the extension from an environment with restricted external extensions (RDS), follow these steps:

1. Connect to your RDS instance.

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. Execute the contents of the `uninstall_kor_search.sql` file to remove the extension:

    ```sql
    \i path/to/uninstall_kor_search.sql
    ```
