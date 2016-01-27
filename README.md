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
        python2.7 python2.7-dev pkg-config libzmq3-dev \
        python-pip python-zmq cython git-buildpackage python-all \
        docbook-xsl docbook-xml xsltproc dh-autoreconf

Afterwards, install Cap'N'Proto from git source (requires 0.6 minium
and no package exists yet for required version):

    git clone https://github.com/sandstorm-io/capnproto.git
    cd capnproto/c++
    git checkout 9afcada819b13
    autoreconf -i
    ./configure
    make -j6 check
    sudo make install
    cd ../..
    rm -rf capnproto

Now install Python Cap'N'Proto interface:

    sudo pip install pycapnp

After this pre-requisites are installed, build the OPNFV Version of Quagga
with:

    make

Packages to be installed end up in debian_package/ subdirectory
Install the package with

    dpkg -i debian_package/*

opnfv-quagga will be automatically started on installation and after any
reboots. To manually stop daemon use `service opnfv-quagga stop` and restart
again with `service opnfv-quagga start`

### Testing:
There is a simple python test script which connects to server and can be
used for a simple installation/running test:

    cd /usr/lib/quagga/qthrift
    ./testclient.py

Expected output:

    /usr/lib/quagga/qthrift$ sudo ./testclient.py 
    0
    received call onStartConfigResyncNotification()
    received call onUpdatePushRoute(u'64603:1111', u'10.3.0.0', 16, u'192.168.1.150', 200)
    received call onUpdatePushRoute(u'64603:1111', u'10.4.1.0', 24, u'192.168.1.151', 200)
    received call onUpdateWithdrawRoute(u'64603:1111', u'10.3.0.0', 16)
    Routes(more=0, errcode=0, updates=[Update(reserved=None, nexthop=u'192.168.1.151', label=200, rd=u'64603:1111', prefix=u'10.4.1.0', prefixlen=24, type=0)])
    received call onUpdatePushRoute(u'64603:1111', u'10.3.0.0', 16, u'192.168.1.150', 200)
    received call onUpdateWithdrawRoute(u'64603:1111', u'10.3.0.0', 16)
    Routes(more=0, errcode=0, updates=[Update(reserved=None, nexthop=u'192.168.1.151', label=200, rd=u'64603:1111', prefix=u'10.4.1.0', prefixlen=24, type=0)])
    [...]

