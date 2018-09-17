#!/bin/bash

#
# Require root access
#

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

rm -rf cloudflare.ini gen-certs.sh nginx/ wp_htdocs/
docker rm -f my-wordpress my-phpmyadmin my-mariadb my-nginx
docker volume rm my-mariadb
docker network rm wp-net
