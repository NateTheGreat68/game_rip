FROM fedora:39
RUN dnf -y install \
	cdrdao \
	mame-tools \
	eject

VOLUME ["/output", "/tmp/ramdisk", "/output_logs"]

ADD app app
WORKDIR /app
ENTRYPOINT ["./rip.sh"]
