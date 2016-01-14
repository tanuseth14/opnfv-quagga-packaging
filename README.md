OPNFV-Quagga
============

Package Scripts to create opnfv-quagga Ubuntu Package.

Package is based on official Quagga from http://www.quagga.net/
and Quagga Source is pulled during the build from the official
Git.
In addition to Quagga, this package will add the Thrift Interface
to integrate Quagga into OPNFV

To build the package, the following Ubuntu package need to be installed:

    apt-get install git autoconf automake libtool make gawk libreadline-dev \
        texinfo dejagnu build-essential fakeroot devscripts equivs lintian \
        dpatch quilt libncurses5-dev texlive-latex-base libcap-dev \
        texlive-generic-recommended imagemagick ghostscript groff \
        hardening-wrapper libpcre3-dev chrpath libpam0g-dev \
        python2.7 python2.7-dev pkg-config libzmq3-dev python-pip

Afterwards, install Cap'N'Proto from git source (requires 0.6 minium
and no package exists yet for required version):

    git clone https://github.com/sandstorm-io/capnproto.git
    cd capnproto/c++
    git checkout 9afcada819b13
    autoreconf -i
    ./configure
    make -j6 check
    sudo make install
    # Fix for debuild only checking /usr/bin and not /usr/local/bin
    sudo ln -s /usr/local/bin/capnp /usr/bin
    cd ../..
    rm -rf capnproto

Now install Python Cap'N'Proto interface:

    sudo pip install pycapnp


