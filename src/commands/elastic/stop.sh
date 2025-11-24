declare current_dir="$PWD"

cd "$HOME"/Applications/docker-elk || exit

blue "Stop the docker-elk stack"
docker-compose down

cd "$current_dir" || exit
