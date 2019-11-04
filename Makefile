ifndef DESTDIR
DESTDIR=/usr/
endif
ifndef CONFDIR
CONFDIR=/etc
endif

install:
	install -v -m 644 simple-kmod-lib.sh $(DESTDIR)/lib/kvc/
	install -v -m 644 simple-kmod.conf $(CONFDIR)/kvc/
	install -v -m 755 simple-kmod-wrapper.sh $(DESTDIR)/lib/kvc/
	ln -sf ../lib/kvc/simple-kmod-wrapper.sh $(DESTDIR)/bin/spkut
