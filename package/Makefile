# +----------------------------------------------------------------------------+
# | Libptc 0.4 * Tools collection                                              | 
# | Copyright (C) 2003-2005 Pozsar Zsolt <pozsarzs@axelero.hu>                 |
# | Makefile                                                                   |
# | Make file for packaging files.                                             |
# +----------------------------------------------------------------------------+

include ../Makefile.global

all:
	@echo

clean:
	@echo

install:
	@echo

uninstall:
	@echo

deb:
	@cp control postinst postrm /tmp
	@chmod 755 /tmp/postinst /tmp/postrm
	@echo "2.0" > /tmp/debian-binary
	@echo "Done."

rpm:
	@cp $(name).spec.info /tmp/$(name).spec
	@cp $(name).spec.post /tmp
	@cp $(name).spec.postun /tmp
	@echo "Done."

tgz:
	@mkdir --parent /tmp/install
	@cp doinst.sh slack-desc /tmp/install/
	@echo "Done."
