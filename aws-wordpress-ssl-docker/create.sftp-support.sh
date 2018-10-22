docker create \
  -p 2223:22 \
  --name sftp-support \
  --mount type=bind,source="$(pwd)"/wp_htdocs,target=/home/support/share \
  atmoz/sftp:alpine \
  support:support:33
