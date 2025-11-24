# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare detailed_format="${args[--detailed]}"
declare secret_id="${args[secret_id]}"

validate-or-refresh-aws-auth

declare secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_id" --profile "$aws_profile" --region "$aws_region")

if [[ $detailed_format == 1 ]]; then
  jq . <<< "$secret_value"
else
  jq '.SecretString' <<< "$secret_value" | sed 's|\\"|"|g' | sed -e 's/"{/{/' -e 's/}"/}/' | jq
fi
