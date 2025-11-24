# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"

validate-or-refresh-aws-auth

spinny-start
aws --profile "$aws_profile" \
  --region "$aws_region" \
  rds describe-db-instances \
  --query 'DBInstances[].DBInstanceIdentifier' \
  --output text
spinny-stop
