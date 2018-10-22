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
echo "1. Setup AWS CLI"
echo "2. Launch Database Instance"
echo "3. Setup SSL using CloudFlare (root and wildcard)"
echo "4. Setup WordPress behind NGINX using Docker"
echo "5. Setup daily backup at 2AM"
echo "6. Setup auto backup removal when older than 2days"
echo "7. Set Timezone to Asia/Bangkok"
echo ""
echo "PREREQUISITES"
echo "1. Edit details in 'export-config.sh'"
echo "2. Please create 'keys' folder"
echo "3. Put your ssh public keys into that folder"
echo ""
echo "Type 'ok' to continue: "
read ok
if [[ $ok != 'ok' ]]; then
  exit 1
fi

#
# Install AWS CLI
#
yum install -y epel-release
yum -y install python-pip
pip install --upgrade pip
pip install --upgrade awscli
yum install -y mysql

#
# Generate Passwords
#
./gen-passwords.sh

#
# Setup AWS CLI
#
./step.1.aws-configure.sh

#
# Import config
#
source export-config.sh

#
# Launch Database Instance
#
./step.2.create-db-parameter-group.sh
./step.3.set-db-timezone.sh
./step.4.create-db-instance.sh
source get-db-endpoint.sh
./step.5.create-db-user.sh

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
yum install -y certbot python2-certbot-dns-cloudflare

# Domain configuration
cat <<EOF > cloudflare.ini
# Cloudflare API credentials used by Certbot
dns_cloudflare_email = $CLOUDFLARE_EMAIL
dns_cloudflare_api_key = $CLOUDFLARE_API_KEY
EOF

chmod u+rw,g-rwx,o-rwx cloudflare.ini

# SSL Challenge
cat <<EOF > gen-certs.sh
#!/bin/bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials cloudflare.ini \
  --server https://acme-v02.api.letsencrypt.org/directory \
  -d $DOMAIN_NAME \
  -d "*.$DOMAIN_NAME"
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
# Required: 960MB Disk Space
#
docker pull nginx:mainline-alpine
docker pull bitnami/phpmyadmin:latest
docker pull wordpress:latest
docker pull atmoz/sftp:alpine

#
# Create docker network
# Named: wp-net
#
docker network create -d=bridge wp-net

#
# Prepare PHP config for WordPress
#
mkdir php
mkdir php/conf.d
cat <<EOF > php/conf.d/uploads.ini
file_uploads = On
upload_max_filesize = 15M
post_max_size = 15M
max_execution_time = 600
EOF

#
# Run wordpress
#
./run.wp.sh

#
# Run sftp
#
./run.sftp-user.sh

#
# Create sftp-support
#
./create.sftp-support.sh

#
# Run phpmyadmin
#
./run.pma.sh

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
#add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /usr/certs/dhparam.pem;
EOF

# Domain SSL snippet
cat <<EOF > nginx/snippets/ssl-"$DOMAIN_NAME".conf
ssl_certificate /usr/certs/$DOMAIN_NAME/fullchain.pem;
ssl_certificate_key /usr/certs/$DOMAIN_NAME/privkey.pem;
EOF

# Default configuration
cat <<EOF > nginx/conf.d/default.conf
server {
  listen       80;
  server_name  localhost;

  location /pma {
    gzip on;
    gzip_min_length 10240;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
    gzip_disable "MSIE [1-6]\.";

    add_header Cache-Control public;

    proxy_pass http://pma/;

    proxy_set_header X-Real-IP  \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$remote_addr;
    proxy_set_header Host \$host;
  }

  location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
  }

  # redirect server error pages to the static page /50x.html
  #
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   /usr/share/nginx/html;
  }
}
EOF

# Domain configuration
cat <<EOF > nginx/conf.d/"$DOMAIN_NAME".conf
server {
  listen 80;
  listen [::]:80;
  server_name $DOMAIN_NAME www.$DOMAIN_NAME;

  return 301 https://www.$DOMAIN_NAME\$request_uri;
}

server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;
  server_name www.$DOMAIN_NAME;
  include snippets/ssl-$DOMAIN_NAME.conf;
  include snippets/ssl-params.conf;
	
  root /usr/share/nginx/html;

  client_max_body_size 15M;

  # global gzip on
  gzip on;
  gzip_min_length 10240;
  gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
  gzip_disable "MSIE [1-6]\.";

  add_header Cache-Control public;

  location / {
    proxy_pass http://wp/;
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
./run.nginx.sh

#
# Setup cron job for SSL Cert Renew
#
crontab -l | { cat; echo "15 3 * * * certbot renew --quiet --deploy-hook \"docker exec -it nginx nginx -s reload\""; } | crontab -

#
# Setup backup
#
timedatectl set-timezone Asia/Bangkok
mkdir backups
chown centos:centos backups
chmod u+rwx,g-wx,o-wx backup.sh

#
# Setup cron job for Backup
#
crontab -l | { cat; echo "0 2 * * * $(pwd)/backup.sh"; } | crontab -
