declare region
# shellcheck disable=SC2154
region="${args[region]}"
if ( grep -q "AWS_REGION" ~/.bashrc ); then
  sed -i "/^AWS_REGION=/c\export AWS_REGION=$region" ~/.bashrc
fi

bash -c "export AWS_REGION=$region; exec bash"
