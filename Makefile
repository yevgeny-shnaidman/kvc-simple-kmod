install:
	sudo install -v -m 644 host/usr/local/lib/kvc-simple-kmod-lib.sh /usr/local/lib/
	sudo install -v -m 644 host/etc/kvc-simple-kmod.conf /etc/
	sudo install -v -m 755 host/usr/local/bin/kvc-simple-kmod-wrapper.sh /usr/local/bin/
	sudo ln -sf ./kvc-simple-kmod-wrapper.sh /usr/local/bin/spkut
