source export-config.sh

aws rds create-db-instance \
  --db-name $AWS_DB_NAME \
  --db-instance-identifier $AWS_DB_INSTANCE_IDENTIFIER \
  --storage-type $AWS_DB_STORAGE_TYPE \
  --allocated-storage $AWS_DB_ALLOCATED_SPACE \
  --db-instance-class $AWS_DB_INSTANCE_CLASS \
  --engine $AWS_DB_ENGINE \
  --engine-version $AWS_DB_ENGINE_VERSION \
  --master-username $AWS_DB_MASTER_USERNAME \
  --master-user-password $AWS_DB_MASTER_PASSWORD \
  --preferred-maintenance-window $AWS_DB_PREFERRED_MAINTENANCE_WINDOW \
  --db-parameter-group-name $AWS_DB_PARAMETER_GROUP_NAME \
  --availability-zone $AWS_AVAILABILITY_ZONE \
  --backup-retention-period $AWS_DB_BACKUP_RETENTION_PERIOD \
  --preferred-backup-window $AWS_DB_PREFERRED_BACKUP_WINDOW \
  --port $AWS_DB_PORT \
  --license-model $AWS_DB_LICENSE_MODEL \
  --no-publicly-accessible