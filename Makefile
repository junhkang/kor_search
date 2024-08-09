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
	install -c -m 644 $(EXTENSION).control $(DESTDIR)$(datadir)/extension/$(EXTENSION).control
	install -c -m 644 $(DATA) $(DESTDIR)$(datadir)/extension/$(DATA)

# Optional: Clean up
clean:
	rm -f src/kor_search.o
	rm -f kor_search.so
	rm -rf /usr/share/postgresql/16/extension/kor_search*
	rm -rf /usr/lib/postgresql/16/lib/kor_search*
	rm -rf /usr/lib/postgresql/16/lib/bitcode/kor_search
