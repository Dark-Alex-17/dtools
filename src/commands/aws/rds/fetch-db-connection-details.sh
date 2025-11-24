# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare db_instance="${args[db_instance]}"

validate-or-refresh-aws-auth

spinny-start
aws --profile "$aws_profile" \
  --region "$aws_region" \
  rds describe-db-instances \
  --query DBInstances[] |\
  jq -r '.[] | select(.DBInstanceIdentifier == "'"$db_instance"'") | .Endpoint | {"address": .Address, "port": .Port}'
spinny-stop
