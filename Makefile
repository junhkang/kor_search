EXTENSION = kor_search
DATA = sql/kor_search--1.0.sql sql/uninstall_kor_search.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)