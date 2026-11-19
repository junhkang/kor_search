.DEFAULT_GOAL := all

MODULE_big = kor_search
OBJS = src/kor_search.o
EXTENSION = kor_search
DATA = kor_search--1.0.0.control sql/kor_search--1.0.0.sql sql/kor_search--1.0.0--1.1.0.sql
DATA_built = sql/kor_search--1.1.0.sql
EXTRA_CLEAN = $(DATA_built)

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

sql/kor_search--1.1.0.sql: sql/kor_search--1.0.0.sql sql/kor_search--1.0.0--1.1.0.sql
	{ sed '/CREATE INDEX IF NOT EXISTS trgm_idx_kor_search_word_synonyms/d' $<; echo; cat $(word 2,$^); } > $@
