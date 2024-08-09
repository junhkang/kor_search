MODULE_big = kor_search
OBJS = src/kor_search.o

EXTENSION = kor_search
EXTVERSION = 1.0.0

DATA = sql/$(EXTENSION)--$(EXTVERSION).sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
