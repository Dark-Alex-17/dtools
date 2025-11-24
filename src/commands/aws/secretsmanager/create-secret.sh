# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare secret_name="${args[--name]}"
declare secret_string="${args[--secret-string]}"

validate-or-refresh-aws-auth

aws secretsmanager create-secret --name "$secret_name" --secret-string "$secret_string" --profile "$aws_profile" --region "$aws_region"
