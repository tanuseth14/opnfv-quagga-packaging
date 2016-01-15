# Debian Package Name
ARCH=$(shell arch)

# URL and Revision for Quagga to checkout
QUAGGAGIT = https://git.netdef.org/scm/osr/quagga-capn-temp.git
QUAGGAREV = 305b727
RELEASE = 1

# URL and Revision for ODL Thrift Interface
QTHRIFTGIT = https://git.netdef.org/scm/osr/odlvpn2bgpd.git
QTHRIFTREV = bf70b5d

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
PATCH = /usr/bin/patch

# Matching Quagga Package Version
VERSION = 0.99.24.99
SOURCEURL = http://www.quagga.net/
# We try to get username and hostname from system, but could be manually set if preferred
#DEBPKGUSER = Nobody
#DEBPKGEMAIL = <nobody@example.com>
DEBPKGUSER = $(shell getent passwd $LOGNAME | cut -d: -f5 | cut -d, -f1)
DEBPKGEMAIL = <$(shell whoami)@$(shell hostname --fqdn)>

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

	
	rm -rf $(DEBPKGBUILD_DIR) 
	git clone $(QUAGGAGIT) $(DEBPKGBUILD_DIR)
	cd $(DEBPKGBUILD_DIR); git checkout $(QUAGGAREV); git submodule init && git submodule update
	$(GROFF) -ms $(DEBPKGBUILD_DIR)/doc/draft-zebra-00.ms -T ascii > $(DEBPKGBUILD_DIR)/doc/draft-zebra-00.txt
	cd $(DEBPKGBUILD_DIR); ./bootstrap.sh
	git clone $(QTHRIFTGIT) $(DEBPKGBUILD_DIR)/qthrift
	cd $(DEBPKGBUILD_DIR)/qthrift; git checkout $(QTHRIFTREV)
	cd $(DEBPKGBUILD_DIR)/qthrift; $(PATCH) -p1 < ../../patches/10-qthrift-bgpd_location.patch	
	# Pack Up Source
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
	$(SED) -i 's|%_QTHRIFTGIT_%|$(QTHRIFTGIT)|g' $(DEBPKGBUILD_DIR)/debian/changelog
	$(SED) -i 's/%_QTHRIFTREV_%/$(QTHRIFTREV)/g' $(DEBPKGBUILD_DIR)/debian/changelog 
	#    debian/rules
	$(SED) -i 's/%_VERSION_%/$(VERSION)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_RELEASE_%/$(RELEASE)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's|%_QUAGGAGIT_%|$(QUAGGAGIT)|g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_QUAGGAREV_%/$(QUAGGAREV)/g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's|%_QTHRIFTGIT_%|$(QTHRIFTGIT)|g' $(DEBPKGBUILD_DIR)/debian/rules
	$(SED) -i 's/%_QTHRIFTREV_%/$(QTHRIFTREV)/g' $(DEBPKGBUILD_DIR)/debian/rules
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
	
	
