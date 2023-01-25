# +----------------------------------------------------------------------------+
# | Libptc 0.4 * Tools collection                                              |
# | Copyright (C) 2003-2005 Pozsar Zsolt <pozsarzs@axelero.hu>                 |
# | Makefile                                                                   |
# | Make file for FreePascal source.                                           |
# +----------------------------------------------------------------------------+

include ../Makefile.global

srcfiles = ptc.pp
libfiles = libptc.so

all:
	@for x in $(srcfiles); do \
	  if [ -e $$x ]; then ppc386 $(fpflags) $$x; echo ""; fi; \
	done
	@echo "Done."

clean:
	@$(rm) *.o
	@$(rm) *.ppu
	@for x in $(libfiles); do if [ -e $$x ]; then $(rm) $$x; fi; done
	@echo "Done."

install:
	@$(install) --directory $(libdir)
	@for x in $(libfiles); do \
	  if [ -e $$x ]; then $(install) --mode $(binmode) $$x $(libdir); fi; \
	done
	@echo "Done."

uninstall:
	@$(rm) $(libdir)/libptc*
	@echo "Done."

deb:
	@$(install) --directory /tmp/$(libdir)
	@for x in $(libfiles); do \
	  if [ -e $$x ]; \
	  then \
	    $(install) --mode $(binmode) $$x /tmp/$(libdir); \
	    md5sum /tmp$(libdir)/$$x | sed 's/\/tmp//' >> /tmp/md5sums; \
	  fi; \
	done
	@echo "Done."

rpm:
	@$(install) --directory /usr/src/RPM/BUILD$(libdir)
	@echo mkdir --mode 755 --parent $(libdir) >> /tmp/$(name).spec.pre
	@for x in $(libfiles); do \
	  if [ -e $$x ]; \
	  then \
	    $(install) --mode $(binmode) $$x /usr/src/RPM/BUILD$(libdir); \
	    echo $(libdir)/$$x >> /tmp/$(name).spec.files; \
	  fi; \
	done
	@echo "Done."

tgz:
	@$(install) --directory /tmp/$(libdir)
	@for x in $(libfiles); do \
	  if [ -e $$x ]; \
	  then \
	    $(install) --mode $(binmode) $$x /tmp/$(libdir); \
	  fi; \
	done
	@echo "Done."
