declare current_dir="$PWD"

[[ -d $HOME/Applications ]] || mkdir "$HOME"/Applications
cd "$HOME"/Applications || exit

[[ -d $HOME/Applications/docker-elk ]] || git clone https://github.com/deviantony/docker-elk.git
cd docker-elk || exit

blue "Build the docker-elk stack just in case a pre-existing version of Elasticsearch needs its nodes upgraded"
docker-compose build

blue "Start the docker-elk setup container"
docker-compose up setup

cd "$current_dir" || exit
