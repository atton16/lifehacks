source export-config.sh

aws rds wait db-instance-available
export AWS_DB_ENDPOINT=$(aws rds describe-db-instances | jq -r '.DBInstances | .[0] | .Endpoint | .Address')

echo "DB Endpoint exported to AWS_DB_ENDPOINT"
echo "--- START DUMP DATA ---"
echo $AWS_DB_ENDPOINT
echo "--- END DUMP DATA ---"
