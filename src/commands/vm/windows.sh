# shellcheck disable=SC2154
declare version="${args[--version]}"
# shellcheck disable=SC2154
declare disk_size="${args[--disk-size]}"
# shellcheck disable=SC2154
declare ram_size="${args[--ram-size]}"
# shellcheck disable=SC2154
declare cpu_cores="${args[--cpu-cores]}"
# shellcheck disable=SC2154
declare share_directory="${args[--share-directory]}"
# shellcheck disable=SC2154
declare persistent_dir_prefix="${args[--persistent-dir-prefix]:-$version}"

if [[ "${args[--wipe-persistent-data]}" == 1 ]]; then
  declare persistent_data_dir="$HOME/.vm/windows/$persistent_dir_prefix"
  if [[ -d "$persistent_data_dir" ]]; then
    yellow "Removing persisted session data for Windows ${version}..."
    rm -rf "$persistent_data_dir"
  else
    red "There's no persisted Windows ${version} session in the specified persistent directory: $persistent_data_dir"
    exit 1
  fi
fi

if [[ "${args[--persistent]}" == 1 ]]; then
  [[ -d "$HOME/.vm/windows/$persistent_dir_prefix" ]] || mkdir -p "$HOME/.vm/windows/$persistent_dir_prefix"
fi

if [[ "${args[--persistent]}" == 1 ]]; then
  container_id=$(docker run -it --rm \
    -v "$HOME/.vm/windows/$persistent_dir_prefix:/storage" \
    -p 8006:8006 \
    -p 3389:3389 \
    --device=/dev/kvm \
    --device=/dev/dri \
    -e "VERSION=$version" \
    -e "DISK_SIZE=${disk_size}G" \
    -e "RAM_SIZE=${ram_size}G" \
    -e "CPU_CORES=$cpu_cores" \
    -v "$share_directory:/data" \
    --cap-add NET_ADMIN \
    --stop-timeout 120 \
    -d \
    dockurr/windows)
else
  container_id=$(docker run -it --rm \
    -p 8006:8006 \
    -p 3389:3389 \
    --device=/dev/kvm \
    --device=/dev/dri \
    -e "VERSION=$version" \
    -e "DISK_SIZE=${disk_size}G" \
    -e "RAM_SIZE=${ram_size}G" \
    -e "CPU_CORES=$cpu_cores" \
    -v "$share_directory:/data" \
    --cap-add NET_ADMIN \
    --stop-timeout 120 \
    -d \
    dockurr/windows)
fi

cleanup() {
  cyan "Stopping Windows container $container_id..."
  docker stop "$container_id" > /dev/null
}

trap cleanup EXIT

until (docker logs "$container_id" 2>&1 | grep -qi "starting boot.*Windows Boot Manager"); do
  blue "Waiting for Windows to boot..."
  sleep 3
done

yes | xfreerdp3 /v:localhost /u:Docker /p:admin +dynamic-resolution
