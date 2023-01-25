# +----------------------------------------------------------------------------+
# | Libptc 0.4 * Tools collection                                              |
# | Copyright (C) 2003-2005 Pozsar Zsolt <pozsarzs@axelero.hu>                 |
# | Makefile                                                                   |
# | Make file for Linux.                                                       |
# +----------------------------------------------------------------------------+
include ./Makefile.global

dirs =	document/hu document package source

all:
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir all; fi; \
	done
	@echo "Source code is compiled."

clean:
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir clean; fi; \
	done
	@echo "Source code is cleaned."

install:
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir install; fi; \
	done
	@package/postinst
	@echo "Programme is installed."

uninstall:
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir uninstall; fi; \
	done
	@echo "Programme is removed."

deb:
	@$(rm) /tmp/md5sums
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir deb; fi; \
	done
	@cd /tmp; tar --create --gzip --file control.tar.gz control md5sums \
	  postinst postrm; tar --create --gzip --file data.tar.gz .$(prefix); \
	  $(rm) $(name)*.deb; ar q $(name)_$(version)_i586.deb \
	  debian-binary control.tar.gz data.tar.gz; \
	  mv $(name)_$(version)_i586.deb /usr/src/; \
	  $(rm) --recursive .$(prefix); $(rm) control control.tar.gz \
	  data.tar.gz debian-binary md5sums postinst postrm
	@echo "Debian package is created under /usr/src directory."

rpm:
	@echo %pre >> /tmp/$(name).spec.pre
	@echo %files >> /tmp/$(name).spec.files
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir rpm; fi; \
	done
	@cat /tmp/$(name).spec.pre /tmp/$(name).spec.post \
	  /tmp/$(name).spec.postun /tmp/$(name).spec.files \
	  package/$(name).spec.changelog >> /tmp/$(name).spec
	@$(rm) /tmp/$(name).spec.pre /tmp/$(name).spec.post \
	  /tmp/$(name).spec.postun /tmp/$(name).spec.files
	@rpm -bb /tmp/$(name).spec 1>/dev/null
	@$(rm) --recursive /usr/src/RPM/BUILD/*
	@$(rm) /tmp/$(name).spec*
	@echo "RedHat package is created under /usr/src/RPM directory."

tgz:
	@for dir in $(dirs); do \
	  if [ -e Makefile ]; then make -C $$dir tgz; fi; \
	done
	@cd /tmp; \
	tar --create --gzip --file $(name)-$(version)-i586-1.tgz .$(prefix) install/*; \
	mv $(name)-$(version)-i586-1.tgz /usr/src/; \
	$(rm) --recursive .$(prefix); \
	$(rm) /tmp/install/slack-desc /tmp/install/doinst.sh;\
	rmdir /tmp/install
	@echo "Slackware package is created under /usr/src directory."
