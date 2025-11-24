blue_bold "Cleaning docker"

blue_bold "Pruning Docker images and containers..."
spinny-start
yes | docker system prune -a
spinny-stop

blue_bold "Pruning Docker volumes..."
spinny-start
yes | docker volume prune
spinny-stop

green_bold "Finished cleaning Docker"
