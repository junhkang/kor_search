MODULE_big = kor_search
OBJS = src/kor_search.o

EXTENSION = kor_search
EXTVERSION = 1.0.0

DATA = sql/$(EXTENSION)--$(EXTVERSION).sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

install:
	@echo "Installing the extension files..."
	install -c -m 755 kor_search.so $(DESTDIR)$(libdir)/kor_search.so
	install -c -m 644 kor_search.control $(DESTDIR)$(datadir)/extension/kor_search.control
	install -c -m 644 sql/kor_search--1.0.0.sql $(DESTDIR)$(datadir)/extension/kor_search--1.0.0.sql

# Optional: Clean up
clean:
	rm -f src/kor_search.o
	rm -f kor_search.so
	rm -rf $(datadir)/extension/kor_search*
	rm -rf $(libdir)/kor_search*
	rm -rf $(libdir)/bitcode/kor_search
