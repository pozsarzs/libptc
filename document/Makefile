# +----------------------------------------------------------------------------+
# | Libptc 0.4 * Tools collection                                              | 
# | Copyright (C) 2003-2005 Pozsar Zsolt <pozsarzs@axelero.hu>                 |
# | Makefile                                                                   |
# | Make file for documents.                                                   |
# +----------------------------------------------------------------------------+

include ../Makefile.global

docfiles = README ChangeLog sample.pal
man3file = libptc.3
langdir =

all:
	@echo

clean:
	@echo

install:
	@$(install) --directory $(datadir)/doc/$(name)-$(version)/$(langdir)
	@for x in $(docfiles); do \
	  if [ -e $$x ]; \
	  then $(install) --mode $(txtmode) $$x $(datadir)/doc/$(name)-$(version)/$(langdir)$$x; \
	  fi; \
	done
	@$(install) --directory $(datadir)/man/$(langdir)man3
	@$(install) --mode $(txtmode) $(man3file) $(datadir)/man/$(langdir)man3
	@echo "Done."

uninstall:
	@$(RM) $(datadir)/doc/$(name)-$(version)/$(langdir)*
	@rmdir $(datadir)/doc/$(name)-$(version)/$(langdir)
	@$(RM) $(datadir)/man/$(langdir)man3/$(man3file)
	@echo "Done."

deb:
	@$(install) --directory /tmp$(datadir)/doc/$(name)-$(version)/$(langdir)
	@for x in $(docfiles); do \
	  if [ -e $$x ]; \
	  then \
	    $(install) --mode $(txtmode) $$x /tmp$(datadir)/doc/$(name)-$(version)/$(langdir)$$x; \
	    md5sum /tmp$(datadir)/doc/$(name)-$(version)/$(langdir)$$x | sed 's/\/tmp//' >> /tmp/md5sums; \
	  fi; \
	done
	@$(install) --directory /tmp$(datadir)/man/$(langdir)man3
	@$(install) --mode $(txtmode) $(man3file) /tmp$(datadir)/man/$(langdir)man3
	@md5sum /tmp$(datadir)/man/$(langdir)man3/$(man3file) | sed 's/\/tmp//' >> /tmp/md5sums;
	@echo "Done."

rpm:
	@$(install) --directory /usr/src/RPM/BUILD$(datadir)/doc/$(name)-$(version)/$(langdir)
	@echo mkdir --mode 755 --parent $(datadir)/doc/$(name)-$(version)/$(langdir) >> /tmp/$(name).spec.pre
	@echo rmdir $(datadir)/doc/$(name)-$(version)/$(langdir) >> /tmp/$(name).spec.postun
	@for x in $(docfiles); do \
	  if [ -e $$x ]; \
	  then \
	    echo $(datadir)/doc/$(name)-$(version)/$(langdir)$$x >> /tmp/$(name).spec.files; \
	    $(install) --mode $(txtmode) $$x /usr/src/RPM/BUILD$(datadir)/doc/$(name)-$(version)/$(langdir); \
	  fi; \
	done
	@$(install) --directory /usr/src/RPM/BUILD$(datadir)/man/$(langdir)man3
	@echo mkdir --mode 755 --parent $(datadir)/man/$(langdir)man3 >> /tmp/$(name).spec.pre
	@echo $(datadir)/man/$(langdir)man3/$(man3file) >> /tmp/$(name).spec.files
	@$(install) --mode $(txtmode) $(man3file) /usr/src/RPM/BUILD$(datadir)/man/$(langdir)man3
	@echo "Done."
tgz:
	@$(install) --directory /tmp$(datadir)/doc/$(name)-$(version)/$(langdir)
	@for x in $(docfiles); do \
	  if [ -e $$x ]; \
	  then \
	    $(install) --mode $(txtmode) $$x /tmp$(datadir)/doc/$(name)-$(version)/$(langdir)$$x; \
	  fi; \
	done
	@$(install) --directory /tmp$(datadir)/man/$(langdir)man3
	@$(install) --mode $(txtmode) $(man3file) /tmp$(datadir)/man/$(langdir)man3
	@echo "Done."
