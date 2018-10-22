#
# CloudFlare configuration
#
export CLOUDFLARE_EMAIL="YOUR CLOUDFLARE EMAIL"
export CLOUDFLARE_API_KEY="YOUR CLOUDFLARE API KEY"

#
# Domain Name
#
export DOMAIN_NAME="YOUR DOMAIN NAME"

#
# AWS General
#
export AWS_PROFILE="YOUR AWS CLI PROFILE NAME"

# New database will be created with this name
export AWS_DB_NAME="YOUR AWS RDS DATABASE NAME"

# Database master password will be set according to the specified value below
export AWS_DB_MASTER_PASSWORD=$(cat pwd.master.txt)

# Database wordpress password will be set according to the specified value below
export AWS_DB_WP_PASSWORD=$(cat pwd.wp.txt)

#
# AWS Advanced
#
export AWS_DB_MASTER_USERNAME="admin"
export AWS_DB_WP_USERNAME="wordpress"

export AWS_DB_PARAMETER_GROUP_NAME="my-mariadb"
export AWS_DB_PARAMETER_GROUP_FAMILY="mariadb10.2"
export AWS_DB_PARAMETER_GROUP_DESCRIPTION="My MariaDB Parameter Group with Timezone set to UTC+7 (Asia/Bangkok)"

export AWS_DB_INSTANCE_IDENTIFIER="my-mariadb"

export AWS_DB_STORAGE_TYPE="gp2"
export AWS_DB_ALLOCATED_SPACE=20
export AWS_DB_INSTANCE_CLASS="db.t2.micro"
export AWS_DB_ENGINE="mariadb"
export AWS_DB_ENGINE_VERSION="10.2"

export AWS_DB_PREFERRED_MAINTENANCE_WINDOW="Sat:20:00-Sat:20:30"

export AWS_AVAILABILITY_ZONE="ap-southeast-1b"

export AWS_DB_BACKUP_RETENTION_PERIOD=35
export AWS_DB_PREFERRED_BACKUP_WINDOW="19:00-19:30"

export AWS_DB_PORT=3306

export AWS_DB_LICENSE_MODEL="general-public-license"
