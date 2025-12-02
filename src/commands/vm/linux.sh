# shellcheck disable=SC2154
declare dist="${args[--dist]}"
# shellcheck disable=SC2154
declare image_url="${args[--image-url]}"
# shellcheck disable=SC2154
declare disk_size="${args[--disk-size]}"
# shellcheck disable=SC2154
declare ram_size="${args[--ram-size]}"
# shellcheck disable=SC2154
declare cpu_cores="${args[--cpu-cores]}"
# shellcheck disable=SC2154
declare share_directory="${args[--share-directory]}"
# shellcheck disable=SC2154
declare usb="${args[--usb]}"
declare -a flags=()

if [[ -n "$usb" ]]; then
  vendor_id="$(udevadm info --query=all --name="$usb" | grep ID_VENDOR_ID | awk -F= '{print $2}')"
  product_id="$(udevadm info --query=all --name="$usb" | grep ID_MODEL_ID | awk -F= '{print $2}')"
  flags+=("--device=/dev/bus/usb")
  flags+=("-e")
  flags+=(ARGUMENTS="-device usb-host,vendorid=0x${vendor_id},productid=0x${product_id}")
fi

if [[ -n $dist ]]; then
  image=$dist
else
  image=$image_url
fi

# shellcheck disable=SC2154
declare persistent_dir_prefix="${args[--persistent-dir-prefix]:-$image}"

if [[ "${args[--wipe-persistent-data]}" == 1 ]]; then
  declare persistent_data_dir="$HOME/.vm/linux/$persistent_dir_prefix"
  if [[ -d "$persistent_data_dir" ]]; then
    yellow "Removing persisted session data for Linux ${image}..."
    rm -rf "$persistent_data_dir"
  else
  red "There's no persisted Linux container (${image}) session in the specified persistent directory: $persistent_data_dir"
  exit 1
  fi
fi

if [[ "${args[--persistent]}" == 1 ]]; then
  [[ -d "$HOME/.vm/linux/$persistent_dir_prefix" ]] || mkdir -p "$HOME/.vm/linux/$persistent_dir_prefix"
fi

if [[ "${args[--no-gui]}" == 1 ]]; then
  if [[ "${args[--persistent]}" == 1 ]]; then
    docker run -it --rm \
      -v "$HOME/.vm/linux/$persistent_dir_prefix:/storage" \
      -p 8006:8006 \
      -p 2222:22 \
      --device=/dev/kvm \
      -e "BOOT=$image" \
      -e "DISK_SIZE=${disk_size}G" \
      -e "RAM_SIZE=${ram_size}G" \
      -e "CPU_CORES=$cpu_cores" \
      -v "$share_directory:/shared" \
      "${flags[@]}" \
      --cap-add NET_ADMIN \
      --stop-timeout 120 \
      qemux/qemu
  else
    docker run -it --rm \
      -p 8006:8006 \
      -p 2222:22 \
      --device=/dev/kvm \
      -e "BOOT=$image" \
      -e "DISK_SIZE=${disk_size}G" \
      -e "RAM_SIZE=${ram_size}G" \
      -e "CPU_CORES=$cpu_cores" \
      -v "$share_directory:/shared" \
      "${flags[@]}" \
      --cap-add NET_ADMIN \
      --stop-timeout 120 \
      qemux/qemu
  fi
else
  if [[ "${args[--persistent]}" == 1 ]]; then
    container_id=$(docker run -it --rm \
      -v "$HOME/.vm/linux/$persistent_dir_prefix:/storage" \
      -p 8006:8006 \
      -p 5900:5900 \
      -p 3389:3389 \
      -p 2222:22 \
      --device=/dev/kvm \
      -e "BOOT=$image" \
      -e "DISK_SIZE=${disk_size}G" \
      -e "RAM_SIZE=${ram_size}G" \
      -e "CPU_CORES=$cpu_cores" \
      -v "$share_directory:/shared" \
      "${flags[@]}" \
      --cap-add NET_ADMIN \
      --stop-timeout 120 \
      -d \
      qemux/qemu)
  else
    container_id=$(docker run -it --rm \
        -p 8006:8006 \
        -p 5900:5900 \
        -p 3389:3389 \
        -p 2222:22 \
        --device=/dev/kvm \
        -e "BOOT=$image" \
        -e "DISK_SIZE=${disk_size}G" \
        -e "RAM_SIZE=${ram_size}G" \
        -e "CPU_CORES=$cpu_cores" \
        -v "$share_directory:/shared" \
        "${flags[@]}" \
        --cap-add NET_ADMIN \
        --stop-timeout 120 \
        -d \
        qemux/qemu)
  fi

  cleanup() {
    cyan "Stopping Linux container $container_id..."
    docker stop "$container_id" > /dev/null
  }

  trap cleanup EXIT

  until (docker logs "$container_id" 2>&1 | grep -qi "starting Boot.*from PciRoot\|starting Boot.*from HD"); do
    blue "Waiting for Linux to boot..."
    sleep 3
  done

  if [[ "${args[--use-rdp]}" == 1 ]]; then
    yes | xfreerdp3 /v:localhost /u:"${args[--rdp-user]}" /p:"${args[--rdp-password]}" +dynamic-resolution
  else
    remmina -c vnc://localhost:5900 --set-option quality=2 --set-option scale=2 --set-option keyboard_grab=1
  fi
fi

