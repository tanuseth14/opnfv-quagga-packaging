#!/bin/bash
#
# Parsing configuration file for qthrift (OPNFV-Quagga)
# and building command line

# Location is hardcoded (in python scripts as well for now)
OPNFVDIR=/usr/lib/quagga
PIDFILE=/var/run/quagga/opnfv-quagga.pid

# exit if old pid exists - otherwise create new pidfile
if [ -f $PIDFILE ]; then
    if ps -p `cat $PIDFILE` >> /dev/null; then
	exit 1
    fi
fi
echo $$ > $PIDFILE

OPNFVCMDLINE=''

# Parse config file if it exists
if [ -f /etc/quagga/qthriftd.conf ]; then
    . /etc/quagga/qthriftd.conf

    if [ -n "$odl_controller_IP" ]; then
        OPNFVCMDLINE="$CMDLINE --server-addr $odl_controller_IP"
    fi
    if [ -n "$odl_controller_thrift_port" ]; then
        OPNFVCMDLINE="$CMDLINE --server-port $odl_controller_thrift_port"
    fi
    if [ -n "$local_thrift_IP" ]; then
        OPNFVCMDLINE="$CMDLINE --client-addr $local_thrift_IP"
    fi
    if [ -n "$local_thrift_port" ]; then
        OPNFVCMDLINE="$CMDLINE --client-port $local_thrift_port"
    fi
    if [ "$qthriftd_debug_log" = "yes" ]; then
        # Use bgp template config with debug options
        OPNFVCMDLINE="$CMDLINE --config $OPNFVDIR/qthrift/bgpd-debug.conf"
        # Enable logging
        rm -f /tmp/qthriftd-log-fifo
        mkfifo /tmp/qthriftd-log-fifo
        ( logger -t qthriftd </tmp/qthriftd-log-fifo & )
        exec >/tmp/qthriftd-log-fifo
    fi
fi

exec /usr/lib/quagga/qthrift/odlvpn2bgpd.py $OPNFVCMDLINE 2>/dev/null

