#!/bin/sh
ps -ef | grep "bgp_quagga" | awk '{print $2}' | xargs kill -9  2&>/dev/null
ps -ef | grep "bgp_thrift" | awk '{print $2}' | xargs kill -9  2&>/dev/null
