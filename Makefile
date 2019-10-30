ifndef DESTDIR
DESTDIR=/usr/
endif
ifndef CONFDIR
CONFDIR=/etc
endif

install:
	sudo install -v -m 644 simple-kmod-lib.sh $(DESTDIR)/lib/kvc/
	sudo install -v -m 644 simple-kmod.conf $(CONFDIR)/kvc/
	sudo install -v -m 755 simple-kmod-wrapper.sh $(DESTDIR)/bin/
	sudo ln -sf ./kvc-simple-kmod-wrapper.sh $(DESTDIR)/bin/spkut
