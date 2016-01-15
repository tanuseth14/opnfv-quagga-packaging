# Debian Package Name
ARCH=$(shell arch)

# URL and Revision for Quagga to checkout
QUAGGAGIT = ssh://git@git-us.netdef.org:7999/osr/quagga-capn.git
QUAGGAREV = ad59d1af
RELEASE = 1

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
SOURCEURL = http://www.quagga.net/
DEBPKGUSER = Nobody
DEBPKGEMAIL = <nobody@example.org>

DEBPKGBUILD_DIR = quaggasrc
# The output dir for the packages needed to install
DEBPKGOUTPUT_DIR = debian_package
DEB_PACKAGES = opnfv-quagga_$(VERSION)-$(RELEASE)_amd64.deb

# Build Date
DATE := $(shell date -u +"%a, %d %b %Y %H:%M:%S %z")

package: 
	@echo 
	@echo
	@echo Building opnfv-quagga $(VERSION) Ubuntu Pkg
	@echo    Using Quagga from $(QUAGGAGIT)
	@echo    opnfv-quagga $(VERSION)-$(RELEASE), Git Rev $(QUAGGAREV)
	@echo -------------------------------------------------------------------------
	@echo

	# Create Source Tar file
	rm -rf $(DEBPKGBUILD_DIR) 
	git clone $(QUAGGAGIT) $(DEBPKGBUILD_DIR)
	cd $(DEBPKGBUILD_DIR); git checkout $(QUAGGAREV); git submodule init && git submodule update
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
	$(SED) -i 's|%_QUAGGAGIT_%|$(QUAGGAGIT)|g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_QUAGGAREV_%/$(QUAGGAREV)/g' $(DEBPKGBUILD_DIR)/debian/changelog
	#    debian/rules
	$(SED) -i 's/%_VERSION_%/$(VERSION)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_RELEASE_%/$(RELEASE)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's|%_QUAGGAGIT_%|$(QUAGGAGIT)|g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_QUAGGAREV_%/$(QUAGGAREV)/g' $(DEBPKGBUILD_DIR)/debian/rules
	#
	# Build the Debian Source and Binary Package
	# TEMP FIX:
	#  - Need to add /usr/local/bin  to path (for captnproto installation outside
	#    of package
	#  - Disable DejaGNU checks as they are currently still broken
	cd $(DEBPKGBUILD_DIR); $(DEBUILD) --set-envvar DEB_BUILD_OPTIONS=nocheck --prepend-path /usr/local/bin -us -uc
	$(MKDIR) $(DEBPKGOUTPUT_DIR)
	$(COPY) $(DEB_PACKAGES) $(DEBPKGOUTPUT_DIR)

clean:
	@echo Cleaning files/directories for opnfv-quagga Package
	$(RMDIR) $(DEBPKGBUILD_DIR)
	$(RMDIR) $(DEBPKGOUTPUT_DIR)
	$(RM) *.deb
	$(RM) *.orig.tar.gz
	$(RM) *.debian.tar.gz
	$(RM) *.build
	$(RM) *.dsc
	$(RM) *.changes
	
	
