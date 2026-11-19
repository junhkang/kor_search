.DEFAULT_GOAL := all

MODULE_big = kor_search
OBJS = src/kor_search.o src/analyze.o
EXTENSION = kor_search
DATA = kor_search--1.0.0.control kor_search--2.0.0.control \
       sql/kor_search--1.0.0.sql sql/kor_search--1.0.0--1.1.0.sql sql/kor_search--1.1.0--2.0.0.sql
DATA_built = sql/kor_search--1.1.0.sql sql/kor_search--2.0.0.sql

CARGO ?= cargo
RUST_TARGET_DIR ?= $(CURDIR)/native/target
RUST_LIB = $(RUST_TARGET_DIR)/release/libkor_search_analyzer.a
SHLIB_LINK = $(RUST_LIB) -ldl -lpthread -lm
ifeq ($(shell uname -s),Linux)
SHLIB_LINK += -Wl,--exclude-libs,ALL
endif
# The linked Rust analyzer is not available as LLVM bitcode for PostgreSQL JIT.
override with_llvm = no

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

$(MODULE_big)$(DLSUFFIX): $(RUST_LIB)

$(RUST_LIB): native/Cargo.toml native/Cargo.lock native/src/lib.rs rust-toolchain.toml
	$(CARGO) build --locked --release --manifest-path native/Cargo.toml --target-dir $(RUST_TARGET_DIR)

sql/kor_search--1.1.0.sql: sql/kor_search--1.0.0.sql sql/kor_search--1.0.0--1.1.0.sql
	{ sed '/CREATE INDEX IF NOT EXISTS trgm_idx_kor_search_word_synonyms/d' $<; echo; cat $(word 2,$^); } > $@

sql/kor_search--2.0.0.sql: sql/kor_search--1.1.0.sql sql/kor_search--1.1.0--2.0.0.sql
	{ cat $<; echo; cat $(word 2,$^); } > $@
