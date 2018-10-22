docker run \
  -d \
  -p 2222:22 \
  --name sftp-user \
  -v /home/centos/keys:/home/user/.ssh/keys:ro \
  --mount type=bind,source="$(pwd)"/wp_htdocs,target=/home/user/share \
  atmoz/sftp:alpine \
  user::33
