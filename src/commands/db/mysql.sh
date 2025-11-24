set -e
trap "docker stop mysql > /dev/null 2>&1" EXIT

# shellcheck disable=SC2154
declare db="${args[--database]}"
declare port="${args[--port]}"
declare persistent_dir_prefix="${args[--persistent-dir-prefix]}"
declare data_dir="${HOME}/.db/mysql/$persistent_dir_prefix"

[[ -d $data_dir ]] || mkdir -p "$data_dir"

start-persistent-mysql-container() {
    docker run -d --rm \
    -v ".:/app:ro" \
    -v "$data_dir:/var/lib/mysql" \
    -p "$port:3306" \
    --name mysql \
    -e MYSQL_ROOT_PASSWORD=password \
    mysql
}

if [[ ${args[--wipe-persistent-data]} == 1 ]]; then
  yellow "Removing persisted data from: $data_dir..."
  rm -rf "$data_dir"
fi

if [[ "${args[--persistent]}" == 1 ]]; then
  start-persistent-mysql-container
  spinny-start
elif [[ "${args[--dump]}" == 1 || "${args[--dump-to-dbml]}" == 1 ]]; then
  start-persistent-mysql-container > /dev/null 2>&1
else
  docker run -d --rm \
    -v ".:/app:ro" \
    -p "$port:3306" \
    --name mysql \
    -e MYSQL_ROOT_PASSWORD=password \
    mysql

  spinny-start
fi

sleep 10

# shellcheck disable=SC2154
if [[ "${args[--tui]}" == 1 ]]; then
  spinny-stop
  if [[ -z $db ]]; then
    harlequin -a mysql -h localhost -p "$port" -U root --password password
  else
    harlequin -a mysql -h localhost -p "$port" -U root --password password --database "$db"
  fi
elif [[ "${args[--dump]}" == 1 ]]; then
  if [[ -z $db ]]; then
    docker exec mysql mysqldump --protocol=tcp -u root -P "$port" --password=password --no-data --all-databases
  else
    docker exec mysql mysqldump --protocol=tcp -u root -P "$port" --password=password --no-data --databases "$db"
  fi
elif [[ "${args[--dump-to-dbml]}" == 1 ]]; then
  if [[ -z $db ]]; then
    env NODE_NO_WARNINGS=1 db2dbml mysql "mysql://root:password@localhost:$port"
    rm -rf dbml-error.log
  else
    env NODE_NO_WARNINGS=1 db2dbml mysql "mysql://root:password@localhost:$port/$db"
    rm -rf dbml-error.log
  fi
else
  spinny-stop
  docker exec -it mysql mysql -u root --password=password
fi
