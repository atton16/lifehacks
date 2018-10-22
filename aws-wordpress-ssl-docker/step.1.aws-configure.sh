source export-config.sh

AWS_PROFILE_NAME=$AWS_PROFILE
unset AWS_PROFILE

aws configure --profile $AWS_PROFILE_NAME

export AWS_PROFILE=$AWS_PROFILE_NAME
unset AWS_PROFILE_NAME
