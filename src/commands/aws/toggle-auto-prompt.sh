set-aws-auto-prompt() {
  if ( grep "AWS_CLI_AUTO_PROMPT" ~/.bashrc > /dev/null 2>&1 ); then
    sed -i "/AWS_CLI_AUTO_PROMPT=/c\export AWS_CLI_AUTO_PROMPT=$1" ~/.bashrc
	fi

	bash -c "export AWS_CLI_AUTO_PROMPT=$1; exec bash"
}

if [[ -z ${AWS_CLI_AUTO_PROMPT} || $AWS_CLI_AUTO_PROMPT == 'off' ]]; then
	set-aws-auto-prompt on
else
	set-aws-auto-prompt off
fi
