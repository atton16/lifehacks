source export-config.sh
source get-db-endpoint.sh

docker run \
  -d \
  --name pma \
  --restart=on-failure:3 \
  --network=wp-net \
  --env DATABASE_HOST=$AWS_DB_ENDPOINT \
  --env DATABASE_PORT_NUMBER=3306 \
  bitnami/phpmyadmin:latest
