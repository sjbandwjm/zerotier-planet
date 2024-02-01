#!/bin/sh

set -x

function start() {
    echo "start zerotier"
    cd /var/lib/zerotier-one && ./zerotier-one -p$(cat /app/config/zerotier-one.port) -d || exit 1
}

function check_zerotier() {
    mkdir -p /var/lib/zerotier-one
    if [ "$(ls -A /var/lib/zerotier-one)" ]; then
        echo "/var/lib/zerotier-one is not empty, start directly"
    else
        mkdir -p /app/config
        echo "/var/lib/zerotier-one is empty, init data"
        echo "${ZT_PORT}" >/app/config/zerotier-one.port
        cp -r /bak/zerotier-one/* /var/lib/zerotier-one/

        cd /var/lib/zerotier-one
        echo "start mkmoonworld"
        openssl rand -hex 16 > authtoken.secret

        ./zerotier-idtool generate identity.secret identity.public
        ./zerotier-idtool initmoon identity.public >moon.json

        if [ -z "$IP_ADDR4" ]; then IP_ADDR4=$(curl -s https://ipv4.icanhazip.com/); fi
        if [ -z "$IP_ADDR6" ]; then IP_ADDR6=$(curl -s https://ipv6.icanhazip.com/); fi

        echo "IP_ADDR4=$IP_ADDR4"
        echo "IP_ADDR6=$IP_ADDR6"

        ZT_PORT=$(cat /app/config/zerotier-one.port)

        echo "ZT_PORT=$ZT_PORT"

        if [ -z "$IP_ADDR4" ]; then stableEndpoints="[\"$IP_ADDR6/${ZT_PORT}\"]"; fi
        if [ -z "$IP_ADDR6" ]; then stableEndpoints="[\"$IP_ADDR4/${ZT_PORT}\"]"; fi
        if [ -n "$IP_ADDR4" ] && [ -n "$IP_ADDR6" ]; then stableEndpoints="[\"$IP_ADDR4/${ZT_PORT}\",\"$IP_ADDR6/${ZT_PORT}\"]"; fi
        if [ -z "$IP_ADDR4" ] && [ -z "$IP_ADDR6" ]; then
            echo "IP_ADDR4 and IP_ADDR6 are both empty!"
            exit 1
        fi

        echo "$IP_ADDR4">/app/config/ip_addr4
        echo "$IP_ADDR6">/app/config/ip_addr6

        echo "stableEndpoints=$stableEndpoints"

        jq --argjson newEndpoints "$stableEndpoints" '.roots[0].stableEndpoints = $newEndpoints' moon.json >temp.json && mv temp.json moon.json
        ./zerotier-idtool genmoon moon.json && mkdir -p moons.d && cp ./*.moon ./moons.d

        cp /app/mkmoonworld-x86_64 ./mkmoonworld-x86_64
        chmod +x ./mkmoonworld-x86_64
        ./mkmoonworld-x86_64 moon.json
        if [ $? -ne 0 ]; then
            echo "mkmoonworld failed!"
            exit 1
        fi

        mkdir -p /app/dist/
        mv world.bin /app/dist/planet
        cp *.moon /app/dist/
        echo -e "mkmoonworld success!\n"
    fi
}

check_zerotier

start