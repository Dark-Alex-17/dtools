# shellcheck disable=SC2155
export aws_region="$(get-aws-region)"
# shellcheck disable=SC2155
export aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
export query="${args[query]}"
# shellcheck disable=SC2154
export start_time="${args[--start-time]}"
# shellcheck disable=SC2154
export end_time="${args[--end-time]}"
eval "log_group_names=(${args[--log-group-name]})"
export log_file=$(mktemp)
trap "rm -f $log_file" EXIT

validate-or-refresh-aws-auth

write-logs() {
	log_group="$1"
  query_id="$(aws logs start-query \
    --log-group-names "$log_group" \
    --start-time "$(date -d "$start_time" +"%s%3N")" \
    --end-time "$(date -d "$end_time" +"%s%3N")" \
    --query-string "$query" \
    --profile "$aws_profile" \
    --region "$aws_region" \
    --output json | jq -r '.queryId // empty')"

  if [[ -z $query_id ]]; then
  	red "Unable to start query for log group: '$log_group'"
  	exit 1
  fi

  until [[ "$(aws logs get-query-results --query-id "$query_id" --profile "$aws_profile" --region "$aws_region" --query status --output text)" == "Complete" ]]; do
  	sleep 1
  done

	aws logs get-query-results --query-id "$query_id" --profile "$aws_profile" --region "$aws_region" | tr -d '\000-\037' | jq -r --arg log_group "$log_group" '.results[] | { "timestamp": (.[] | select(.field == "@timestamp") | .value), "message": (.[] | select(.field == "@message") | .value), "logGroup": $log_group }' >> "$log_file"
}
export -f write-logs

parallel -j8 write-logs {} ::: ${log_group_names[*]}

jq -rs '. | sort_by(.timestamp) | map("\(.timestamp) \(.logGroup) \(.message)")[]' "$log_file" | sed '/^$/d'
