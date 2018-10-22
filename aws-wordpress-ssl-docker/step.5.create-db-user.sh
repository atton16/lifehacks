source export-config.sh
source get-db-endpoint.sh

mysql \
  -u $AWS_DB_MASTER_USERNAME \
  --password=$AWS_DB_MASTER_PASSWORD \
  -h $AWS_DB_ENDPOINT \
  -e "CREATE USER '${AWS_DB_WP_USERNAME}'@'%' IDENTIFIED BY '${AWS_DB_WP_PASSWORD}'; GRANT ALL PRIVILEGES ON ${AWS_DB_NAME}.* TO '${AWS_DB_WP_USERNAME}'@'%'; FLUSH PRIVILEGES;"
