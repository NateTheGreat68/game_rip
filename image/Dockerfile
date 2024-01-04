FROM fedora:39
RUN dnf -y install \
	cdrdao \
	mame-tools \
	eject

ENV USERID=0
ENV GROUPID=0

VOLUME ["/output", "/tmp/ramdisk"]

ADD app app
WORKDIR /app
ENTRYPOINT ["./rip.sh"]
