# kor_search

PostgreSQL�� �ѱ��� �ؽ�Ʈ �˻� Ȯ��.

## ����

`kor_search` Ȯ���� �ѱ��� �ؽ�Ʈ �˻��� ���� LIKE �� tsvector ��� �˻� ����� �����մϴ�. ��� �ѱ۷� ��ȯ�Ͽ� LIKE ������ �����մϴ�.

## ��ġ

### ���� PostgreSQL �Ǵ� EC2����

1. ���� PostgreSQL Ȯ���� �����ϰ� ��ġ�Ϸ��� ���� ��ɾ �����ϼ���:

    ```sh
    make
    sudo make install
    ```

2. �׷� ����, PostgreSQL �����ͺ��̽��� �����Ͽ� Ȯ���� Ȱ��ȭ�մϴ�:

    ```sh
    psql -U your_username -d your_database
    CREATE EXTENSION kor_search;
    ```

### Amazon RDS����

1. RDS �ν��Ͻ��� �����մϴ�. ���� ���, `psql`�� ����Ͽ� ������ �� �ֽ��ϴ�:

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `kor_search--1.0.sql` ������ ������ ���� �����Ͽ� Ȯ���� Ȱ��ȭ�մϴ�:

    ```sql
    \i path/to/kor_search--1.0.sql
    ```

## �Լ�

- `kor_like(input_text text, search_text text)`: `search_text`�� �ش��ϴ� synonyms�� `input_text`�� ���ԵǾ� �ִ��� LIKE ������ Ȯ���մϴ�.
- `kor_search_tsvector(input_text text, search_text text)`: `search_text`�� �ش��ϴ� synonyms�� `input_text`�� tsvector�� ���ԵǾ� �ִ��� Ȯ���մϴ�.

## ��� ����

1. `kor_like` �Լ� ��� ����:

    ```sql
    -- 'lg' Ű����� '����', '����'�� �˻�
    SELECT kor_like('�̰��� ���� ��ǰ�Դϴ�', 'lg');  -- ���: true
    SELECT kor_like('�̰��� ���� ��ǰ�Դϴ�', 'lg');  -- ���: true

    -- 'samsung' Ű����� '�Ｚ'�� �˻�
    SELECT kor_like('�̰��� �Ｚ ��ǰ�Դϴ�', 'samsung');  -- ���: true
    ```

2. `kor_search_tsvector` �Լ� ��� ����:

    ```sql
    -- 'lg' Ű����� '����', '����'�� �˻�
    SELECT kor_search_tsvector('�̰��� ���� ��ǰ�Դϴ�', 'lg');  -- ���: true
    SELECT kor_search_tsvector('�̰��� ���� ��ǰ�Դϴ�', 'lg');  -- ���: true

    -- 'samsung' Ű����� '�Ｚ'�� �˻�
    SELECT kor_search_tsvector('�̰��� �Ｚ ��ǰ�Դϴ�', 'samsung');  -- ���: true
    ```

## �ܾ� ��ȯ ���̺� ����

�ܾ� ��ȯ ���̺� ���ο� Ű����� ���� �߰��� �� �ֽ��ϴ�. ���� ���, 'apple' Ű���忡 ���� ���� �߰��Ϸ��� ������ ���� �մϴ�:

```sql
INSERT INTO kor_search_word_transform (keyword, synonyms)
VALUES ('apple', ARRAY['����', '���']);

## ����

### ���� PostgreSQL �Ǵ� EC2����

���� PostgreSQL �Ǵ� EC2���� Ȯ���� �����Ϸ��� ���� �ܰ踦 ��������:

1. PostgreSQL �����ͺ��̽��� �����մϴ�.

    ```sh
    psql -U your_username -d your_database
    ```

2. Ȯ���� �����մϴ�.

    ```sql
    DROP EXTENSION kor_search;
    ```

### Amazon RDS����

Amazon RDS���� Ȯ���� �����Ϸ��� ���� �ܰ踦 ��������:

1. RDS �ν��Ͻ��� �����մϴ�.

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `uninstall_kor_search.sql` ������ ������ ���� �����Ͽ� Ȯ���� �����մϴ�:

    ```sql
    \i path/to/uninstall_kor_search.sql
    ```
