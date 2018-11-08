SUBDIRS = man utils src tests

EXTRA_DIST = doc include

dist-hook:
	for cvsdir in `find $(distdir) -name CVS`; do \
	  [ -d "$$cvsdir" ] && rm -rf "$$cvsdir" ; \
	done
