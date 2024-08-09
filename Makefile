MODULE_big = kor_search
OBJS = src/kor_search.o

EXTENSION = kor_search
EXTVERSION = 1.0.0

DATA = sql/$(EXTENSION)--$(EXTVERSION).sql

# Ensure control file is installed correctly
EXTRA_CLEAN = $(EXTENSION).control

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# Explicitly specify the control file location
DATA_built = $(EXTENSION).control

$(EXTENSION).control: $(EXTENSION).control.in
	sed 's/MODVERSION/$(EXTVERSION)/' $< > $@

all: $(EXTENSION).so $(EXTENSION).control

install: all
	$(INSTALL_DATA) $(DATA) $(DESTDIR)$(datadir)/extension/
	$(INSTALL_DATA) $(DATA_built) $(DESTDIR)$(datadir)/extension/
	$(INSTALL_PROGRAM) $(MODULE_big).so $(DESTDIR)$(pkglibdir)/
