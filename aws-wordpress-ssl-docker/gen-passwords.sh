export AWS_DB_MASTER_PASSWORD=$(</dev/urandom tr -dc '23456789abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ' | head -c16; echo "")
export AWS_DB_WP_PASSWORD=$(</dev/urandom tr -dc '23456789abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ' | head -c16; echo "")

echo $AWS_DB_MASTER_PASSWORD > pwd.master.txt
echo $AWS_DB_WP_PASSWORD > pwd.wp.txt
