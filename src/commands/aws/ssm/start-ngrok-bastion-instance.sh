set -e
# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
# shellcheck disable=SC2154
declare subnet_id="${args[--subnet-id]}"
declare hostname="${args[--hostname]}"
declare port="${args[--port]}"
declare ngrok_url="${args[--ngrok-url]}"
declare ngrok_auth_token="${args[--ngrok-auth-token]}"

validate-or-refresh-aws-auth

cleanup() {
	if [[ -n "$instance_id" ]]; then
		yellow "Terminating the EC2 instance..."
		aws --profile "$aws_profile" --region "$aws_region" ec2 terminate-instances --instance-ids "$instance_id"
	fi
}

trap "cleanup" EXIT

cyan "Ensuring the AmazonSSMRoleForInstancesQuickSetup role exists..."
if ! aws --profile "$aws_profile" --region "$aws_region" iam get-role --role-name AmazonSSMRoleForInstancesQuickSetup > /dev/null 2>&1; then
	yellow "Creating the AmazonSSMRoleForInstancesQuickSetup role..."
	aws --profile "$aws_profile" --region "$aws_region" iam create-role \
		--role-name AmazonSSMRoleForInstancesQuickSetup \
		--assume-role-policy-document '{"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' \
		> /dev/null

	yellow "Attaching the AmazonSSMManagedInstanceCore policy to the role..."
	aws --profile "$aws_profile" --region "$aws_region" iam attach-role-policy \
		--role-name AmazonSSMRoleForInstancesQuickSetup \
		--policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

	yellow "Attaching the AmazonSSMPatchAssociation policy to the role..."
	aws --profile "$aws_profile" --region "$aws_region" iam attach-role-policy \
		--role-name AmazonSSMRoleForInstancesQuickSetup \
		--policy-arn arn:aws:iam::aws:policy/AmazonSSMPatchAssociation

	yellow "Creating the AmazonSSMRoleForInstancesQuickSetup instance profile..."
	aws --profile "$aws_profile" --region "$aws_region" iam create-instance-profile \
		--instance-profile-name AmazonSSMRoleForInstancesQuickSetup \
		> /dev/null

	yellow "Adding the AmazonSSMRoleForInstancesQuickSetup role to the instance profile..."
	aws --profile "$aws_profile" --region "$aws_region" iam add-role-to-instance-profile \
		--instance-profile-name AmazonSSMRoleForInstancesQuickSetup --role-name AmazonSSMRoleForInstancesQuickSetup \
		> /dev/null
	sleep 5
fi

cyan "Launching an EC2 instance..."
# shellcheck disable=SC2155
declare instance_id=$({
	aws --profile "$aws_profile" --region "$aws_region" ec2 run-instances \
		--image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
		--instance-type t2.micro \
		--count 1 \
		--subnet-id "$subnet_id" \
		--iam-instance-profile Name=AmazonSSMRoleForInstancesQuickSetup \
		--user-data $'#!/bin/bash\nwget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz\ntar xvzf ./ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin' \
		--query Instances[0].InstanceId \
    --output text
})

get-instance-state() {
	aws --profile "$aws_profile" --region "$aws_region" ec2 describe-instance-status \
		--instance-ids "$instance_id" \
		--query InstanceStatuses[0] |\
		jq '. | {instance: .InstanceStatus.Details[0].Status, system: .SystemStatus.Details[0].Status}'
}

status_checks=$(get-instance-state)
until [[ $(jq -r '.instance' <<< "$status_checks") == "passed" && $(jq -r '.system' <<< "$status_checks") == "passed" ]]; do
	yellow "Waiting for instance to start..."
	sleep 1
	status_checks=$(get-instance-state)
done

green 'Instance is running!'

yellow "Adding the ngrok authtoken to the instance..."
aws --profile "$aws_profile" --region "$aws_region" ssm start-session \
	--target "$instance_id" \
	--document-name AWS-StartInteractiveCommand \
	--parameters command="ngrok config add-authtoken $ngrok_auth_token"

yellow 'Starting ngrok tunnel...'
cyan 'The resource will be available at the following URL: '
cyan_bold "https://$ngrok_url"

cyan "\nYou will be able to point Postman to the above URL to access the resource."

yellow_bold "\nPress 'Ctrl+C' to stop the ngrok tunnel and to terminate the EC2 instance."

red_bold "This information will only be displayed once. Please make a note of it.\n"

read -rp "To acknowledge receipt and continue, press 'Enter'." </dev/tty

aws --profile "$aws_profile" --region "$aws_region" ssm start-session \
	--target "$instance_id" \
	--document-name AWS-StartInteractiveCommand \
	--parameters command="ngrok http ${hostname}:${port} --domain $ngrok_url"

yellow "Terminating the EC2 instance..."
aws --profile "$aws_profile" --region "$aws_region" ec2 terminate-instances --instance-ids "$instance_id"
