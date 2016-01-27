OPNFV-Quagga
============

Package Scripts to create opnfv-quagga Ubuntu Package.

Package is based on official Quagga from http://www.quagga.net/
and Quagga Source is pulled during the build from the official
Git.
In addition to Quagga, this package will add the Thrift Interface
to integrate Quagga into OPNFV

To install all the required build essentials, run:

    apt-get install `cat requirements.txt`

See [requirements.txt](/requirements.txt/) for a list of required packages
for build.

After this pre-requisites are installed, build the OPNFV Version of Quagga
with:

    make

Packages to be installed end up in debian_package/ subdirectory
Install the packages with

    dpkg -i debian_package/*
    # Fix missing dependencies from public repo
    apt-get -f install

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

