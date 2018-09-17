#!/bin/bash

#
# Require root access
#

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

#
# Prompt for user input
#
echo "* WordPress auto setup *"
echo ""
echo "REMARK: This script only runs on CentOS"
echo ""
echo "THIS SCRIPT WILL"
echo "1. Setup SSL using CloudFlare (root and wildcard)"
echo "2. Setup WordPress behind NGINX using Docker"
echo "3. Setup phpMyAdmin behind NGINX using Docker (localhost access only)"
echo "4. Setup daily backup at 2AM"
echo "5. Setup auto backup removal when older than 2days"
echo ""

echo "Please specify your CloudFlare email:"
read cloudflare_email

echo "Please specify your CloudFlare API Key:"
echo "HINT: My Profile > API Keys > Global API Key > View"
read cloudflare_api_key

echo "Please specify your (root) domain name:"
read domain_name

echo "Please specify(create) MariaDB root password:"
echo "(your input will be hidden)"
echo "Note: You can create strong password at"
echo "      https://passwordsgenerator.net"
read -s mariadb_root_pwd

echo "Creating WordPress DB User: wordpress"
echo "Please specify(create) WordPress DB password:"
echo "(your input will be hidden)"
read -s wordpress_db_pwd

#
# Prepare files & folders
#
mkdir wp_htdocs

#
# Prerequisites
# Required: 5.6MB Disk Space
#

# Install text editor
yum install -y nano vi

# Install Let's Encrypt
yum install -y epel-release
yum install -y certbot python2-certbot-dns-cloudflare

# Domain configuration
cat <<EOF > cloudflare.ini
# Cloudflare API credentials used by Certbot
dns_cloudflare_email = $cloudflare_email
dns_cloudflare_api_key = $cloudflare_api_key
EOF

chmod u+rw,g-rwx,o-rwx cloudflare.ini

# SSL Challenge
cat <<EOF > gen-certs.sh
#!/bin/bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials cloudflare.ini \
  --server https://acme-v02.api.letsencrypt.org/directory \
  -d $domain_name \
  -d "*.$domain_name"
EOF

chmod u+rwx,g-wx,o-wx gen-certs.sh

./gen-certs.sh

#
# Docker CE
# Required: 200MB Disk Space
#

# Setup the Repo
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE
yum install -y docker-ce

# Configure Docker CE to run at boot
systemctl enable docker

# Start Docker CE
systemctl start docker

#
# Pull necessary images
# Required: 960GB Disk Space
#
docker pull nginx:mainline-alpine
docker pull mariadb:latest
docker pull phpmyadmin/phpmyadmin:latest
docker pull wordpress:latest

#
# Create docker network
# Named: wp-net
#
docker network create -d=bridge wp-net


#
# Run MariaDB (Mysql)
#
docker run \
  -d \
  -p 3306:3306 \
  --restart=always \
  --network=wp-net \
  --name my-mariadb \
  -v my-mariadb:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=$mariadb_root_pwd \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=$wordpress_db_pwd \
  mariadb:latest

#
# Run phpmyadmin
#
docker run \
  -d \
  --restart=always \
  --network=wp-net \
  --name my-phpmyadmin \
  -e MYSQL_ROOT_PASSWORD=$mariadb_root_pwd \
  -e PMA_HOST=my-mariadb \
  -e PMA_PORT=3306 \
  phpmyadmin/phpmyadmin:latest


#
# Run wordpress
#
docker run \
  -d \
  --restart=on-failure:3 \
  --network=wp-net \
  --name my-wordpress \
  --mount type=bind,source="$(pwd)"/wp_htdocs,target=/var/www/html \
  -e WORDPRESS_DB_HOST=my-mariadb:3306 \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=$wordpress_db_pwd \
  wordpress:latest

#
# Prepare files for nginx
#
mkdir nginx
mkdir nginx/conf.d
mkdir nginx/snippets
mkdir nginx/ssl
mkdir nginx/ssl/certs
openssl dhparam -out nginx/ssl/certs/dhparam.pem 2048

# SSL Params snippet
cat <<EOF > nginx/snippets/ssl-params.conf
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# disable HSTS header for now
#add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /usr/certs/dhparam.pem;
EOF

# Domain SSL snippet
cat <<EOF > nginx/snippets/ssl-"$domain_name".conf
ssl_certificate /usr/certs/$domain_name/fullchain.pem;
ssl_certificate_key /usr/certs/$domain_name/privkey.pem;
EOF


# Domain configuration
cat <<EOF > nginx/conf.d/"$domain_name".conf
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name localhost;

  location /pma {
    gzip on;
    gzip_min_length 10240;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
    gzip_disable "MSIE [1-6]\.";

    add_header Cache-Control public;

    proxy_pass http://my-phpmyadmin/;

    proxy_set_header X-Real-IP  \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$remote_addr;
    proxy_set_header Host \$host;
  }
}

server {
  listen 80;
  listen [::]:80;
  server_name $domain_name www.$domain_name;

  return 301 https://www.$domain_name\$request_uri;
}

server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;
  server_name www.$domain_name;
  include snippets/ssl-$domain_name.conf;
  include snippets/ssl-params.conf;
	
  root /usr/share/nginx/html;

  # global gzip on
  gzip on;
  gzip_min_length 10240;
  gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
  gzip_disable "MSIE [1-6]\.";

  add_header Cache-Control public;

  location / {
    proxy_pass http://my-wordpress/;
    proxy_buffering on;
    proxy_buffers 12 12k;
    proxy_redirect off;
    proxy_http_version 1.1;

    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$host;
  }

}
EOF

#
# Run nginx
#
docker run \
  -d \
  -p 80:80 \
  -p 443:443 \
  --restart=on-failure:3 \
  --network=wp-net \
  --name my-nginx \
  --mount type=bind,source="$(pwd)"/nginx/conf.d/$domain_name.conf,target=/etc/nginx/conf.d/$domain_name.conf,readonly \
  --mount type=bind,source="$(pwd)"/nginx/snippets/ssl-$domain_name.conf,target=/etc/nginx/snippets/ssl-$domain_name.conf,readonly \
  --mount type=bind,source="$(pwd)"/nginx/snippets/ssl-params.conf,target=/etc/nginx/snippets/ssl-params.conf,readonly \
  --mount type=bind,source=/etc/letsencrypt/live/$domain_name/fullchain.pem,target=/usr/certs/$domain_name/fullchain.pem,readonly \
  --mount type=bind,source=/etc/letsencrypt/live/$domain_name/privkey.pem,target=/usr/certs/$domain_name/privkey.pem,readonly \
  --mount type=bind,source="$(pwd)"/nginx/ssl/certs/dhparam.pem,target=/usr/certs/dhparam.pem,readonly \
  nginx:mainline-alpine

#
# Setup cron job for SSL Cert Renew
#
crontab -l | { cat; echo "15 3 * * * certbot renew --quiet --deploy-hook \"docker exec -it my-nginx nginx -s reload\""; } | crontab -

#
# Setup backup
#
mkdir backups
chown centos:centos backups

# Backup script
cat <<EOF > backup.sh
#!/bin/bash

#
# Require root access
#

if [[ \$UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo \$0 \$*"
    exit 1
fi

# For cron job
cd $(pwd)

current_time=\$(date "+%Y.%m.%d-%H.%M.%S")

touch wp_htdocs/.maintenance
tar --exclude='.maintenance' -zcf backups/wp_\$current_time.tar.gz wp_htdocs/
docker exec my-mariadb /usr/bin/mysqldump -u root --password=$mariadb_root_pwd wordpress > backups/wp_\$current_time.sql
rm wp_htdocs/.maintenance
# Delete files that is older than 2 days
find ./backups -mtime +2 -type f -delete
EOF

chmod u+rwx,g-wx,o-wx backup.sh

#
# Setup cron job for Backup
#
crontab -l | { cat; echo "0 2 * * * $(pwd)/backup.sh"; } | crontab -
