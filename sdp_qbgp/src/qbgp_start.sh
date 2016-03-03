#!/bin/sh
cd /opt/qbgp
export LD_LIBRARY_PATH=`pwd`
./bgp_quagga > quagga.start.log 2>&1 &
