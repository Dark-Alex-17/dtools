# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare detailed_format="${args[--detailed]}"

validate-or-refresh-aws-auth

# shellcheck disable=SC2155
declare secrets=$(aws secretsmanager list-secrets --profile "$aws_profile" --region "$aws_region")

if [[ $detailed_format == 1 ]]; then
  jq . <<< "$secrets"
else
  jq -r '.SecretList[].Name' <<< "$secrets"
fi
