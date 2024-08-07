MODULE_big = kor_search
OBJS = src/kor_search.o  # src 폴더 내의 kor_search.c 파일을 참조하도록 경로 수정

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
