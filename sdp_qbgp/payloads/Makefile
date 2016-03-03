QBGPROOT=$(shell pwd)

all:
	rpmbuild --buildroot $(QBGPROOT)/builddir --define "_sourcedir $(QBGPROOT)/src" -bb QBGP.spec --target x86_64
	mv /usr/src/packages/RPMS/x86_64/qbgp*.rpm .
	rm -rf $(QBGPROOT)/builddir




