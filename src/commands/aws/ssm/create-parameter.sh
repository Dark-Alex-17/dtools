# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare name="${args[--name]}"
declare value="${args[--value]}"

validate-or-refresh-aws-auth

aws ssm put-parameter --name "$name" --value "$value" --type String --profile "$aws_profile" --region "$aws_region"
