source export-config.sh

docker run \
  -d \
  -p 80:80 \
  -p 443:443 \
  --restart=on-failure:3 \
  --network=wp-net \
  --name nginx \
  --mount type=bind,source="$(pwd)"/nginx/conf.d/default.conf,target=/etc/nginx/conf.d/default.conf,readonly \
  --mount type=bind,source="$(pwd)"/nginx/conf.d/$DOMAIN_NAME.conf,target=/etc/nginx/conf.d/$DOMAIN_NAME.conf,readonly \
  --mount type=bind,source="$(pwd)"/nginx/snippets/ssl-$DOMAIN_NAME.conf,target=/etc/nginx/snippets/ssl-$DOMAIN_NAME.conf,readonly \
  --mount type=bind,source="$(pwd)"/nginx/snippets/ssl-params.conf,target=/etc/nginx/snippets/ssl-params.conf,readonly \
  --mount type=bind,source=/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem,target=/usr/certs/$DOMAIN_NAME/fullchain.pem,readonly \
  --mount type=bind,source=/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem,target=/usr/certs/$DOMAIN_NAME/privkey.pem,readonly \
  --mount type=bind,source="$(pwd)"/nginx/ssl/certs/dhparam.pem,target=/usr/certs/dhparam.pem,readonly \
  nginx:mainline-alpine
