# Debian Package Name
ARCH=$(shell arch)

# URL and Revision for Quagga to checkout
QUAGGAGIT = http://git.savannah.nongnu.org/r/quagga.git
QUAGGAREV = 941789e

MKDIR = /bin/mkdir -p
MV = /bin/mv
RM = /bin/rm -f
RMDIR = /bin/rm -rf
COPY = /bin/cp -a
TAR = /bin/tar
SED = /bin/sed
THISDIR = $(shell pwd)
INSTALL = /usr/bin/install
DEBUILD = /usr/bin/debuild
GROFF = /usr/bin/groff

# Matching Quagga Package Version
VERSION = 0.99.24.99
RELEASE = git.$(QUAGGAREV)
SOURCEURL = http://www.quagga.net/
DEBPKGUSER = Nobody
DEBPKGEMAIL = <nobody@example.org>

DEBPKGBUILD_DIR = quaggasrc

# Build Date
DATE := $(shell date -u +"%a, %d %b %Y %H:%M:%S %z")

package: 
	@echo 
	@echo
	@echo Building opnfv-quagga $(VERSION) Ubuntu Pkg
	@echo    Using Quagga from $(QUAGGAGIT), Git Rev $(QUAGGAREV)
	@echo -------------------------------------------------------------------------
	@echo

	# Create Source Tar file
	rm -rf $(DEBPKGBUILD_DIR) 
	git clone $(QUAGGAGIT) $(DEBPKGBUILD_DIR)
	cd $(DEBPKGBUILD_DIR); git checkout $(QUAGGAREV)
	$(GROFF) -ms $(DEBPKGBUILD_DIR)/doc/draft-zebra-00.ms -T ascii > $(DEBPKGBUILD_DIR)/doc/draft-zebra-00.txt
	cd $(DEBPKGBUILD_DIR); ./bootstrap.sh
	cd ..
	tar --exclude=".*" -czf opnfv-quagga_$(VERSION).orig.tar.gz $(DEBPKGBUILD_DIR)

	# Build Debian Pkg Scripts and configs from templates
	rm -rf debian
	cp -a debian_template $(DEBPKGBUILD_DIR)/debian
	#
	# Fix up the debian package build scripts
	#    debian/changelog
	$(SED) -i 's/%_VERSION_%/$(VERSION)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_RELEASE_%/$(RELEASE)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's|%_SOURCEURL_%|$(SOURCEURL)|g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_DATE_%/$(DATE)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_USER_%/$(DEBPKGUSER)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_EMAIL_%/$(DEBPKGEMAIL)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	#    debian/rules
	$(SED) -i 's/%_VERSION_%/$(VERSION)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_RELEASE_%/$(RELEASE)/g' $(DEBPKGBUILD_DIR)/debian/rules
	#
	# Build the Debian Source and Binary Package
	cd $(DEBPKGBUILD_DIR); $(DEBUILD) -us -uc

clean:
	@echo Cleaning files/directories for opnfv-quagga Package
	$(RMDIR) $(DEBPKGBUILD_DIR)
	$(RM) *.deb
	$(RM) *.orig.tar.gz
	$(RM) *.debian.tar.gz
	$(RM) *.build
	$(RM) *.dsc
	$(RM) *.changes
	
	
