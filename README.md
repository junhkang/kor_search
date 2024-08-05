<<<<<<< HEAD
=======
# kor_search

PostgreSQL�� �ѱ��� �ؽ�Ʈ �˻� Ȯ��.

## ����

`kor_search` Ȯ���� �ѱ��� �ؽ�Ʈ �˻��� ���� LIKE �� tsvector ��� �˻� ����� �����մϴ�. ��� �ѱ۷� ��ȯ�Ͽ� LIKE ������ �����մϴ�.

## ��ġ

### ���� PostgreSQL �Ǵ� EC2����

1. Ȯ���� �����ϰ� ��ġ�Ϸ��� ���� ��ɾ �����ϼ���:

    ```sh
    make
    sudo make install
    ```

2. �����ͺ��̽����� Ȯ���� ����Ϸ��� ���� SQL�� �����ϼ���:

    ```sql
    CREATE EXTENSION kor_search;
    ```

### Amazon RDS����

1. RDS �ν��Ͻ��� �����մϴ�. ���� ���, `psql`�� ����Ͽ� ������ �� �ֽ��ϴ�:

    ```sh
    psql -h your-rds-endpoint -U your-username -d your-database
    ```

2. `kor_search--1.0.sql` ������ ������ ���� �����մϴ�:

    ```sql
    \i path/to/kor_search--1.0.sql
    ```

## �Լ�

- `kor_like(input_text text, search_text text)`: `search_text`�� `input_text`�� ���ԵǾ� �ִ��� LIKE ������ Ȯ���մϴ�.
- `kor_search_tsvector(input_text text, search_text text)`: `search_text`�� `input_text`�� tsvector�� ���ԵǾ� �ִ��� Ȯ���մϴ�.

## ��� ����

```sql
SELECT kor_like('�ȳ��ϼ���', '�ȳ�');  -- ���: true

SELECT kor_search_tsvector('�ȳ��ϼ���', '�ȳ�');  -- ���: true
>>>>>>> 1641cf0 (initial commit)
