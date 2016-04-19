# Building and Installing on SUSE 11 SP3

This explains on how the the `opnfv-quagga` package can be built and installed on SUSE 11 SP3 
(and potential other version, but they are not tested)

SUSE is a RPM based system, but has a few changes, specially the init system which seems to be
different. SUSE distribution lacks several packages which are available for RedHat or Debian
based system which need to be built during this process as well.

We keep 2 sections in this document: Requirements for building the system [Build System](#build-system) 
and requirements for installing/running [Execution System](#execution-system) the resulting RPMs

## Build System

### Required packages to install (from SUSE's official packages)

	sudo zypper install \
		git \
		autoconf \
		automake \
		pkgconfig \
		python-devel \
		libtool \
		make \
		gawk \
		texinfo \
		dejagnu \
		quilt \
		groff \
		chrpath \
		imagemagick \
		ghostscript \
		readline-devel \
		libcap-devel \
		python-setuptools \
		libuuid-devel \
		fdupes

### Additional packages (may have to be rebuilt from Source)

#### Compiler (_Needs to be done first!_)
The package requires a GNU C / C++ compiler of at least version 4.8 to build. SUSE 11 SP3 only
provides up to 4.7.

Note: __If you already have a gcc 4.8 or higher, then skip this step__

The new version of GCC can be built as follows:

1. Install a either GCC 4.3 or 4.7 (to build the new compiler) from SUSE's provided packages
   (and other already installed GCC compiler might work as well)

		zypper install gcc4.3 gcc43-c++ gcc43-locale gcc-ada

2. Download and build the new compiler (rpmbuild will take a long time!)

		wget someplace/gcc48-4.8.5-166.1.src.rpm
		rpmbuild --rebuild gcc48-4.8.5-166.1.src.rpm

3. Install and activate the new compiler (as an additional compiler)

		zypper install /usr/src/packages/RPMS/x86_64/gcc48-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libgcc_s1-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libgomp1-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libasan0-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libtsan0-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libatomic1-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libitm1-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/libgcc_s1-4.8.5-166.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/cpp48-4.8.5-166.1.x86_64.rpm
		
		sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 3  \
			--slave /usr/bin/c++ c++ /usr/bin/g++-4.8 \
			--slave /usr/bin/cc cc /usr/bin/gcc-4.8 \
			--slave /usr/bin/cpp cpp /usr/bin/cpp-4.8 \
			--slave /usr/bin/g++ g++ /usr/bin/g++-4.8  \
			--slave /usr/bin/gcov gcov /usr/bin/gcov-4.8 \
			--slave /usr/bin/gnat gnat /usr/bin/gnat-4.8 \
			--slave /usr/bin/gnatbind gnatbind /usr/bin/gnatbind-4.8 \
			--slave /usr/bin/gnatbl gnatbl /usr/bin/gnatbl-4.8 \
			--slave /usr/bin/gnatchop gnatchop /usr/bin/gnatchop-4.8 \
			--slave /usr/bin/gnatclean gnatclean /usr/bin/gnatclean-4.8 \
			--slave /usr/bin/gnatfind gnatfind /usr/bin/gnatfind-4.8 \
			--slave /usr/bin/gnatkr gnatkr /usr/bin/gnatkr-4.8 \
			--slave /usr/bin/gnatlink gnatlink /usr/bin/gnatlink-4.8 \
			--slave /usr/bin/gnatls gnatls /usr/bin/gnatls-4.8 \
			--slave /usr/bin/gnatmake gnatmake /usr/bin/gnatmake-4.8 \
			--slave /usr/bin/gnatname gnatname /usr/bin/gnatname-4.8 \
			--slave /usr/bin/gnatprep gnatprep /usr/bin/gnatprep-4.8 \
			--slave /usr/bin/gnatxref gnatxref /usr/bin/gnatxref-4.8 \
			--slave /usr/bin/gprmake gprmake /usr/bin/gprmake-4.8

		sudo update-alternatives --config gcc
			## And select gcc-4.8 in the menu

#### ZeroMQ
ZeroMQ Version 4.x is required for the package and needs to be built from Source on SUSE 11
Any already existing ZeroMQ 4.x package should work as well.
(Please make sure to build ZeroMQ _AFTER_ installing and activating the GCC compiler)

1. Download and build ZeroMQ

		wget someplace/zeromq-4.0.7-1.src.rpm
		rpmbuild --rebuild zeromq-4.0.7-1.src.rpm

2. Install ZeroMQ (including development package)

		sudo zypper install \
			/usr/src/packages/RPMS/x86_64/zeromq-4.0.7-1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/zeromq-devel-4.0.7-1.x86_64.rpm

#### Python Support packages
A few additional (or newer than available from SUSE) Python packages are required.

1. Download and build `python-setuptools`

		wget someplace/python-setuptools-20.2.2-75.1.src.rpm
		rpmbuild --rebuild python-setuptools-20.2.2-75.1.src.rpm

2. Download and build `python-six`

		wget someplace/python-six-1.10.0-56.1.src.rpm
		rpmbuild --rebuild python-six-1.10.0-56.1.src.rpm

3. Download and build `python-Cython`

		wget someplace/python-Cython-0.21.1-64.1.src.rpm
		rpmbuild --rebuild python-Cython-0.21.1-64.1.src.rpm

4. Download and build `python-pyzmq`

		wget someplace/python-pyzmq-2.2.0.1-4.1.src.rpm
		rpmbuild --rebuild python-pyzmq-2.2.0.1-4.1.src.rpm

5. Install python packages

		sudo zypper install \
			/usr/src/packages/RPMS/x86_64/python-setuptools-20.2.2-75.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/python-six-1.10.0-56.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/python-Cython-0.21.1-64.1.x86_64.rpm \
			/usr/src/packages/RPMS/x86_64/python-pyzmq-2.2.0.1-4.1.x86_64.rpm
			
### Build `opnfv-quagga`

	make

### Packages required to distribute for running `opnfv-quagga`
The following packages need to be distributed for the execution system:

1. From the official SUSE SDK set (other versions should work as well)

		python-ply-2.5-1.17.x86_64.rpm

2. Additional support libraries (built during this process)

		/usr/src/packages/RPMS/x86_64/libstdc++6-4.8.5-166.1.x86_64.rpm
		/usr/src/packages/RPMS/x86_64/python-pyzmq-2.2.0.1-4.1.x86_64.rpm
		/usr/src/packages/RPMS/x86_64/zeromq-4.0.7-1.x86_64.rpm

3. `opnfv-quagga` packages (built by `make` above)

		rpm_packages/libcapnp-*.x86_64.rpm
		rpm_packages/pycapnp-*.x86_64.rpm
		rpm_packages/opnfv-quagga-*.x86_64.rpm
		rpm_packages/thriftpy-*.x86_64.rpm

## Execution System

### Install packages

Install the libraries (provided by the build system):

	sudo zypper install \
		./python-ply-2.5-1.17.x86_64.rpm \
		./libstdc++6-4.8.5-166.1.x86_64.rpm \
		./python-pyzmq-2.2.0.1-4.1.x86_64.rpm \
		./zeromq-4.0.7-1.x86_64.rpm

Install the `opnfv-quagga` packages:

	sudo zypper install \
		./libcapnp-*.x86_64.rpm \
		./pycapnp-*.x86_64.rpm \
		./opnfv-quagga-*.x86_64.rpm \
		./thriftpy-*.x86_64.rpm

### Start/Stop and Check `opnfv-quagga`

The daemon gets started automatically by default and will
be configured to start on boot

- Start `opnfv-quagga`:

		sudo /etc/init.d/opnfv-quagga start
	
- Stop `opnfv-quagga`:

		sudo /etc/init.d/opnfv-quagga stop

- To check the status:

		sudo /etc/init.d/opnfv-quagga status

- Disable automatic startup on boot

		chkconfig opnfv-quagga off

- Re-Enable automatic startup on boot

		chkconfig opnfv-quagga on

