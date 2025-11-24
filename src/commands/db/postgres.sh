set -e
trap "docker stop postgres > /dev/null 2>&1" EXIT

# shellcheck disable=SC2154
declare db="${args[--database]}"
declare port="${args[--port]}"
declare persistent_dir_prefix="${args[--persistent-dir-prefix]}"
declare data_dir="${HOME}/.db/postgres/$persistent_dir_prefix"
eval "schema=(${args[--schema]:-})"

[[ -d $data_dir ]] || mkdir -p "$data_dir"

start-persistent-postgres-container() {
    docker run -d --rm \
    -v ".:/data" \
    -v "$data_dir:/var/lib/postgresql" \
    -p "$port:5432" \
    --name postgres \
    -e POSTGRES_PASSWORD=password \
    postgres
}

if [[ ${args[--wipe-persistent-data]} == 1 ]]; then
  yellow "Removing persisted data from: $data_dir..."
  sudo rm -rf "$data_dir"
fi

if [[ "${args[--persistent]}" == 1 ]]; then
  start-persistent-postgres-container
  spinny-start
elif [[ "${args[--dump]}" == 1 || "${args[--dump-to-dbml]}" == 1 ]]; then
  start-persistent-postgres-container > /dev/null 2>&1
else
  docker run -d --rm \
    -v ".:/data" \
    -p "$port:5432" \
    --name postgres \
    -e POSTGRES_PASSWORD=password \
    postgres

  spinny-start
fi

sleep 3

# shellcheck disable=SC2154
if [[ "${args[--tui]}" == 1 ]]; then
  spinny-stop
  harlequin -a postgres "postgres://postgres:password@localhost:$port/$db" -f .
elif [[ "${args[--dump]}" == 1 ]]; then
  docker exec postgres pg_dump -U postgres -s -F p -E UTF-8
elif [[ "${args[--dump-to-dbml]}" == 1 ]]; then
  if [[ "${#schema[@]}" != 0 ]]; then
    schemas_parameter="schemas=$(echo -n "${schema[*]}" | tr ' ' ',')"
    env NODE_NO_WARNINGS=1 db2dbml postgres "postgresql://postgres:password@localhost:$port/$db?$schemas_parameter"
    rm -rf dbml-error.log
  else
    env NODE_NO_WARNINGS=1 db2dbml postgres "postgresql://postgres:password@localhost:$port/$db"
    rm -rf dbml-error.log
  fi
else
  spinny-stop
  docker exec -it postgres psql -U postgres
fi
