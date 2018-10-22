source export-config.sh

aws rds create-db-parameter-group \
  --db-parameter-group-name $AWS_DB_PARAMETER_GROUP_NAME \
  --db-parameter-group-family $AWS_DB_PARAMETER_GROUP_FAMILY \
  --description $AWS_DB_PARAMETER_GROUP_DESCRIPTION
