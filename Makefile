# Debian Package Name
ARCH=$(shell arch)

# URL and Revision for Quagga to checkout
QUAGGAGIT = https://git.netdef.org/scm/osr/quagga-capn-temp.git
QUAGGAREV = 305b727
RELEASE = 1

# URL and Revision for ODL Thrift Interface
QTHRIFTGIT = https://git.netdef.org/scm/osr/odlvpn2bgpd.git
QTHRIFTREV = bf70b5d

# URL for Python Thrift Library
THRIFTPYGIT = https://git.netdef.org/scm/osr/thriftpy.git

# URL for Capnproto Library
CAPNPROTOGIT = https://git.netdef.org/scm/osr/capnproto.git

MKDIR = /bin/mkdir -p
MV = /bin/mv
RM = /bin/rm -f
RMDIR = /bin/rm -rf
COPY = /bin/cp -a
TAR = /bin/tar
SED = /bin/sed
THISDIR = $(shell pwd)
DEPPKGDIR = $(THISDIR)/depend
INSTALL = /usr/bin/install
DEBUILD = /usr/bin/debuild
GROFF = /usr/bin/groff
PATCH = /usr/bin/patch
GBP = /usr/bin/gbp

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


all: $(DEBPKGOUTPUT_DIR)/$(DEB_PACKAGES) $(DEPPKGDIR)/python-thriftpy-deb $(DEPPKGDIR)/capnproto-deb
	
$(DEBPKGOUTPUT_DIR)/$(DEB_PACKAGES): 
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
	cd $(DEBPKGBUILD_DIR); patch -Np1 -i ../patches/0001-Allow-to-use-capnp-0.5.99.patch
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
	cd $(DEBPKGBUILD_DIR); $(DEBUILD) --set-envvar DEB_BUILD_OPTIONS=nocheck -us -uc
	# cd $(DEBPKGBUILD_DIR); $(DEBUILD) --set-envvar DEB_BUILD_OPTIONS=nocheck --prepend-path /usr/local/bin -us -uc
	$(MKDIR) $(DEBPKGOUTPUT_DIR)
	$(COPY) $(DEB_PACKAGES) $(DEBPKGOUTPUT_DIR)

$(DEPPKGDIR)/capnproto-deb:
	@echo 
	@echo
	@echo Building capnproto Ubuntu Pkg 0.5.99
	@echo    Using capnproto from $(CAPNPROTOGIT)
	@echo -------------------------------------------------------------------------
	@echo
	#
	# Create directory for depend packages and cleanup previous thriftpy packages
	$(MKDIR) $(DEPPKGDIR)
	rm -rf $(DEPPKGDIR)/capnproto*
	rm -rf $(DEPPKGDIR)/libcapnp*
	rm -rf $(DEBPKGOUTPUT_DIR)/capnproto*
	rm -rf $(DEBPKGOUTPUT_DIR)/libcapnp*
	#
	# Build debian package
	git clone $(CAPNPROTOGIT) $(DEPPKGDIR)/capnproto
	cd $(DEPPKGDIR)/capnproto; tar czf capnproto_0.5.99.orig.tar.gz c++
	cd $(DEPPKGDIR)/capnproto/c++; $(DEBUILD) -us -uc
	#
	# Save Package to Output Directory
	$(MKDIR) $(DEBPKGOUTPUT_DIR)
	$(COPY) $(DEPPKGDIR)/capnproto/capnproto*.deb $(DEBPKGOUTPUT_DIR)
	$(COPY) $(DEPPKGDIR)/capnproto/libcapnp*.deb $(DEBPKGOUTPUT_DIR)
	# 
	# Create dummy flag file with filename for Makefile logic
	cd debian_package; ls capnproto*.deb > $(DEPPKGDIR)/capnproto-deb 2> /dev/null
	cd debian_package; ls libcapnp-[0-9]*.deb > $(DEPPKGDIR)/libcapnp-deb 2> /dev/null
	cd debian_package; ls libcapnp-dev*.deb > $(DEPPKGDIR)/libcapnp-dev-deb 2> /dev/null

$(DEPPKGDIR)/python-thriftpy-deb:
	@echo 
	@echo
	@echo Building thriftpy Ubuntu Pkg
	@echo    Using thriftpy from $(THRIFTPYGIT)
	@echo -------------------------------------------------------------------------
	@echo
	#
	# Create directory for depend packages and cleanup previous thriftpy packages
	$(MKDIR) $(DEPPKGDIR)
	rm -rf $(DEPPKGDIR)/thriftpy*
	rm -rf $(DEPPKGDIR)/python-thriftpy*
	rm -rf $(DEBPKGOUTPUT_DIR)/python-thriftpy*
	#
	# Build debian package
	git clone $(THRIFTPYGIT) $(DEPPKGDIR)/thriftpy
	cd $(DEPPKGDIR)/thriftpy; $(GBP) buildpackage -us -uc
	#
	# Save Package to Output Directory
	$(MKDIR) $(DEBPKGOUTPUT_DIR)
	$(COPY) $(DEPPKGDIR)/python-thriftpy*.deb $(DEBPKGOUTPUT_DIR)
	# 
	# Create dummy flag file with filename for Makefile logic
	cd debian_package; ls python-thriftpy*.deb > $(DEPPKGDIR)/python-thriftpy-deb 2> /dev/null

clean:
	@echo Cleaning files/directories for opnfv-quagga Package
	$(RMDIR) $(DEBPKGBUILD_DIR)
	$(RMDIR) $(DEBPKGOUTPUT_DIR)
	$(RMDIR) $(DEPPKGDIR)
	$(RM) *.deb
	$(RM) *.orig.tar.gz
	$(RM) *.debian.tar.gz
	$(RM) *.build
	$(RM) *.dsc
	$(RM) *.changes
	
	
