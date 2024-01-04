FROM fedora:39
RUN dnf -y install \
	cdrdao \
	mame-tools \
	eject

VOLUME ["/output", "/tmp/ramdisk"]

ADD app app
WORKDIR /app
ENTRYPOINT ["./rip.sh"]
