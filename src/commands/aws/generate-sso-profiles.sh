# shellcheck disable=SC2154
declare aws_region="${args[--default-cli-region]}"
declare sso_region="${args[--sso-region]}"
declare sso_start_url="${args[--sso-start-url]}"
declare backup="${args[--backup]}"

set -e

if [[ -z $aws_region ]]; then
	aws_region="$sso_region"
fi

export AWS_REGION=$aws_region

write-profile-to-config() {
  profileName=$1
  ssoStartUrl=$2
  ssoRegion=$3
  ssoAccountId=$4
  ssoRoleName=$5
  defaultRegion=$6

	blue_bold "Creating profile $profileName"

	cat <<-EOF >> "$HOME"/.aws/config
		[profile $profileName]
		sso_start_url   = $ssoStartUrl
		sso_region      = $ssoRegion
		sso_account_id  = $ssoAccountId
		sso_role_name   = $ssoRoleName
		region          = $defaultRegion
	EOF
}

if [[ $backup == 1 ]]; then
	yellow "Backing up old AWS config"
	mv "$HOME"/.aws/config "$HOME"/.aws/config.bak
fi

login() {
	ssoLoggedIn=$(find "$HOME/.aws/sso/cache" -type f ! -name "botocore*" -exec jq -r '.accessToken | select(. != null)' {} \; | wc -l)
	if [[ $ssoLoggedIn == 0 || ! -f "$HOME"/.aws/config ]]; then
		yellow_bold "You must first be logged into AWS with at least one profile. Logging in now..."
		[[ -f "$HOME"/.aws/config ]] || touch "$HOME"/.aws/config
	
		export AWS_PROFILE=''
		export AWS_REGION=''
		/usr/bin/expect<<-EOF
			set force_conservative 1
			set timeout 120
			match_max 100000
			spawn aws configure sso
			expect "SSO session name (Recommended):"
			send -- "session\r"
			expect "SSO start URL"
			send -- "$sso_start_url\\r"
			expect "SSO region"
			send -- "$sso_region\r"
			expect {
			  "SSO registration scopes" {
			    send "sso:account:access\\r"
			    exp_continue
			  }
			  -re {(.*)accounts available to you(.*)} {
			    send "\\r"
			    exp_continue
			  }
			  -re {(.*)roles available to you(.*)} {
			    send "\\r"
			    exp_continue
			  }
			  "CLI default client Region"
			}
			send "\r\r\r\r"
			expect eof
		EOF
	elif ! (aws sts get-caller-identity > /dev/null 2>&1); then
		red_bold "You must be logged into AWS before running this script."
		yellow "Logging in via SSO. Follow the steps in the opened browser to log in."

		profiles=$(awk '/\[profile*/ { print substr($2, 1, length($2)-1); }' ~/.aws/config | tail -1)

		if ! aws sso login --profile "${profiles[0]}"; then
			red_bold "Unable to login. Please try again."
			exit 1
		fi

		green "Logged in!"
	fi

	blue "Fetching SSO access token"
	profiles=$(awk '/\[profile*/ { print substr($2, 1, length($2)-1); }' ~/.aws/config | tail -1)
	# shellcheck disable=SC2227
	ACCESS_TOKEN=$(find "$HOME/.aws/sso/cache" -type f ! -name 'botocore*' -exec jq -r '.accessToken | select(. != null)' {} 2>/dev/null \; | tail -1)
}

login

if ! (aws sso list-accounts --profile "${profiles[0]}" --region "$aws_region" --access-token "$ACCESS_TOKEN" --output json > /dev/null 2>&1); then
	red "Unable to use existing SSO access token. Wiping tokens and generating new tokens..."
	rm "$HOME"/.aws/sso/cache/*.json
	login
fi

aws sso list-accounts --profile "${profiles[0]}" --region "$aws_region" --access-token "$ACCESS_TOKEN" --output json | jq '.accountList[]' -rc | while read -r account; do
	declare accountId
	declare accountName
    accountId="$(echo "$account" | jq -rc '.accountId')"
    accountName="$(echo "$account" | jq -rc '.accountName | ascii_downcase | gsub(" "; "-")')"

    aws sso list-account-roles --profile "${profiles[0]}" --region "$aws_region" --access-token "$ACCESS_TOKEN" --output json --account-id "$accountId" | jq '.roleList[].roleName' -rc | while read -r roleName; do
			declare profileName
			profileName="$accountName-$roleName"

			if ! (grep -q "$profileName" ~/.aws/config); then
				blue "Creating profiles for account $accountName"
					write-profile-to-config "$accountName-$roleName" "$sso_start_url" "$sso_region" "$accountId" "$roleName" "$aws_region"
			fi
    done
done

green_bold "Successfully generated profiles from AWS SSO!"

