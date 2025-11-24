declare current_dir="$PWD"

cd "$HOME"/Applications/docker-elk || exit

blue "Start the docker-elk stack"
docker-compose up -d

yellow_bold "\n\n\nDefault credentials:"
yellow "Username: elastic"
yellow "Password: changeme"

cd "$current_dir" || exit
