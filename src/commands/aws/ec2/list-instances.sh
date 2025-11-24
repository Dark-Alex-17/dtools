# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare detailed_format="${args[--detailed]}"
eval "filters=(${args[--filter]:-})"

validate-or-refresh-aws-auth
spinny-start

# shellcheck disable=SC2155
declare instances=$(aws ec2 describe-instances --profile "$aws_profile" --region "$aws_region")
spinny-stop

# Must be ordered by non-nested fields first
declare -A instance_field_mappings=(
  [instance-id]='InstanceId'
  [instance-type]='InstanceType'
  [private-dns-name]='PrivateDnsName'
  [private-ip-address]='PrivateIpAddress'
  [public-dns-name]='PublicDnsName'
  [subnet-id]='SubnetId'
  [vpc-id]='VpcId'
  [tags]='Tags'
  [launch-time]='LaunchTime'
  [architecture]='Architecture'
  [instance-profile]='IamInstanceProfile'
  [security-groups]='SecurityGroups'
  [availability-zone]='"AvailabilityZone": .Placement.AvailabilityZone'
  [state]='"State": .State.Name'
  [os]='"OS": .PlatformDetails'
)

if [[ $detailed_format == 1 ]]; then
  jq . <<< "$instances"
elif [[ -v filters[@] ]]; then
  declare object_def=""

  for filter_name in "${!instance_field_mappings[@]}"; do
    # shellcheck disable=SC2154
    if printf '%s\0' "${filters[@]}" | grep -Fxqz -- "$filter_name"; then
      object_def+="${instance_field_mappings[$filter_name]}, "
    fi
  done

  jq '.Reservations[].Instances[] | { '"$object_def"' }' <<< "$instances"
else
  jq '.Reservations[].Instances[] | pick(.InstanceId, .PrivateDnsName, .PrivateIpAdress, .PublicDnsName, .SubnetId, .VpcId, .Tags)' <<< "$instances"
fi
