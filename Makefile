MODULE_big = kor_search
OBJS = src/kor_search.o  # src ���� ���� kor_search.c ������ �����ϵ��� ��� ����

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
