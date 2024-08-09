
PG_CONFIG = pg_config
INSTALL = install
INSTALL_DATA = $(INSTALL) -m 644
PGSHAREDIR = $(shell $(PG_CONFIG) --sharedir)
PGINCLUDEDIR = $(shell $(PG_CONFIG) --includedir-server)
EXTENSION = kor_search

all:
	make -C src

install:
	$(INSTALL_DATA) src/$(EXTENSION).control $(DESTDIR)$(PGSHAREDIR)/extension/
	$(INSTALL_DATA) src/$(EXTENSION)--*.sql $(DESTDIR)$(PGSHAREDIR)/extension/
