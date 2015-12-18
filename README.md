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
        hardening-wrapper libpcre3-dev chrpath libpam0g-dev

