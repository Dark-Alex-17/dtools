filter_postgres_not_running() {
	if docker container ls | grep -q 'postgres'; then
	  red_bold "The PostgreSQL container is already running. Try stopping the container and trying again."
	fi
}

filter_mysql_not_running() {
	if docker container ls | grep -q 'mysql'; then
	  red_bold "The MySQL container is already running. Try stopping the container and trying again."
	fi
}
