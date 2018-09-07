#!/bin/bash

if [ -z $DO_TOKEN ]; then
    echo "DO token undefined"
    exit 1
fi

if [ -z $DO_FLOATING_IP ]; then
    echo "DO floating IP undefined"
    exit 1
fi

ID=$(curl -s http://169.254.169.254/metadata/v1/id)
HAS_FLOATING_IP=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/active)

if [ $HAS_FLOATING_IP = "false" ]; then
    n=0
    while [ $n -lt 10 ]
    do
        python3 /assign-ip $DO_FLOATING_IP $ID && break
        n=$((n+1))
        sleep 3
    done
fi
