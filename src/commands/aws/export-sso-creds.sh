# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
declare aws_region="$(get-aws-region)"

validate-or-refresh-aws-auth

bash -c "eval \"\$(aws --profile $aws_profile --region $aws_region configure export-credentials --format env)\"; export AWS_REGION=$aws_region; exec bash"
