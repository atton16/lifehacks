source export-config.sh
source get-db-endpoint.sh

docker run \
  -d \
  --restart=on-failure:3 \
  --network=wp-net \
  --name wp \
  --mount type=bind,source="$(pwd)"/wp_htdocs,target=/var/www/html \
  -v "$(pwd)"/php/conf.d/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini:ro \
  -e WORDPRESS_DB_HOST=$AWS_DB_ENDPOINT:3306 \
  -e WORDPRESS_DB_NAME=$AWS_DB_NAME \
  -e WORDPRESS_DB_USER=$AWS_DB_WP_USERNAME \
  -e WORDPRESS_DB_PASSWORD=$AWS_DB_WP_PASSWORD \
  wordpress:latest
