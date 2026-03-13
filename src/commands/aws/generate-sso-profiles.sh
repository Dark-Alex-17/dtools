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
	sso_logged_in=$(find "$HOME/.aws/sso/cache" -type f ! -name "botocore*" -exec jq -r '.accessToken | select(. != null)' {} \; | wc -l)
	if [[ $sso_logged_in == 0 || ! -f "$HOME"/.aws/config ]]; then
		yellow_bold "You must first be logged into AWS with at least one profile. Logging in now..."
		red_bold "You will be required to finish the login process, so control will be returned to you after logging in with your browser"
		[[ -f "$HOME"/.aws/config ]] || touch "$HOME"/.aws/config
	
		export AWS_PROFILE=''
		export AWS_REGION=''
		export SSO_START_URL="$sso_start_url"
		export SSO_REGION="$sso_region"
		/usr/bin/expect <(cat <<-'EOF'
			set timeout 120
			match_max 100000

			set sso_start_url $env(SSO_START_URL)
			set sso_region    $env(SSO_REGION)

			spawn env TERM=dumb aws configure sso

			expect -re {SSO session name \(Recommended\):\s*$}
			send -- "session\r"

			expect -re {SSO start URL \[None\]:\s*$}
			send -- "$sso_start_url\r"

			expect -re {SSO region \[None\]:\s*$}
			send -- "$sso_region\r"

			expect -re {SSO registration scopes \[sso:account:access\]:\s*$}
			send -- "sso:account:access\r"

			expect -re {.*accounts available to you\s*}

			interact
			EOF
			) 2>/dev/null

		green "Logged in!"
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

if ! (aws sso list-accounts --profile "${profiles[0]}" --region "$sso_region" --access-token "$ACCESS_TOKEN" --output json > /dev/null 2>&1); then
	red "Unable to use existing SSO access token. Wiping tokens and generating new tokens..."
	rm "$HOME"/.aws/sso/cache/*.json
	login
fi

aws sso list-accounts --profile "${profiles[0]}" --region "$sso_region" --access-token "$ACCESS_TOKEN" --output json | jq '.accountList[]' -rc | while read -r account; do
	declare account_id
	declare account_name
  account_id="$(echo "$account" | jq -rc '.accountId')"
  account_name="$(echo "$account" | jq -rc '.accountName | ascii_downcase | gsub(" "; "-")')"

  aws sso list-account-roles --profile "${profiles[0]}" --region "$sso_region" --access-token "$ACCESS_TOKEN" --output json --account-id "$account_id" |\
  	jq '.roleList[].roleName' -rc |\
  	while read -r role_name; do
			declare profileName
			profileName="$account_name-$role_name"

			if ! (grep -q "$profileName" ~/.aws/config); then
				blue "Creating profiles for account $account_name"
					write-profile-to-config "$account_name-$role_name" "$sso_start_url" "$sso_region" "$account_id" "$role_name" "$aws_region"
			fi
	  done
done

green_bold "Successfully generated profiles from AWS SSO!"

