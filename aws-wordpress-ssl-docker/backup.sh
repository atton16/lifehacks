#!/bin/bash

#
# Require root access
#

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# For cron job
cd $(pwd)

source export-config.sh
source get-db-endpoint.sh

current_time=$(date "+%Y.%m.%d-%H.%M.%S")

touch wp_htdocs/.maintenance
tar --exclude='.maintenance' -zcf backups/wp_$current_time.tar.gz wp_htdocs/
mysqldump \
  -u $AWS_DB_MASTER_USERNAME \
  --password=$AWS_DB_MASTER_PASSWORD \
  -h $AWS_DB_ENDPOINT \
  $AWS_DB_NAME \
  > backups/wp_$current_time.sql
rm wp_htdocs/.maintenance
# Delete files that is older than 2 days
find ./backups -mtime +2 -type f -delete
