source export-config.sh

aws rds modify-db-parameter-group \
  --db-parameter-group-name $AWS_DB_PARAMETER_GROUP_NAME \
  --parameters "ParameterName=time_zone,ParameterValue=Asia/Bangkok,ApplyMethod=immediate"
