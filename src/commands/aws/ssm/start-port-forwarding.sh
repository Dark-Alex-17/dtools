# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
declare aws_region="$(get-aws-region)"
# shellcheck disable=SC2154
declare instance_id="${args[instance-id]}"
declare remote_port="${args[--remote-port]}"
declare local_port="${args[--local-port]}"
declare host="${args[--host]}"

validate-or-refresh-aws-auth

aws ssm start-session \
  --profile "$aws_profile" \
  --region "$aws_region" \
  --target "$instance_id" \
  --document-name "AWS-StartPortForwardingSessionToRemoteHost" \
  --parameters "portNumber=${remote_port},localPortNumber=${local_port},host=${host}"
