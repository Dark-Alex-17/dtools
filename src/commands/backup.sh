# shellcheck disable=SC2154
declare item="${args[item]}"
declare backup_dest="${args[--backup-dest]}"
declare move="${args[--move]}"

if [[ $move == 1 ]]; then
  if [[ -d $item ]]; then
    if [[ -n $backup_dest ]]; then
      yellow_bold "Backing up directory to: ${backup_dest}${item}-bak/. Original directory will no longer exist."
      mv -f "$item" "${backup_dest}${item}-bak"
    else
      yellow_bold "Backing up directory to: ${item}-bak/. Original directory will no longer exist."
      mv -f "$item" "${item}-bak"
    fi
  elif [[ -f $item ]]; then
    if [[ -n $backup_dest ]]; then
      yellow_bold "Creating backup file: ${backup_dest}${item}.bak. Original file will no longer exist."
      mv -f "$item" "${backup_dest}${item}.bak"
    else
      yellow_bold "Creating backup file: ${item}.bak. Original file will no longer exist."
      mv -f "$item" "${item}.bak"
    fi
  fi
else
  if [[ -d $item ]]; then
    if [[ -n $backup_dest ]]; then
      yellow_bold "Backing up directory to: ${backup_dest}${item}-bak/."
      cp -rf "$item" "${backup_dest}${item}-bak"
    else
      yellow_bold "Backing up directory to: ${item}-bak/."
      cp -rf "$item" "${item}-bak"
    fi
  elif [[ -f $item ]]; then
    if [[ -n $backup_dest ]]; then
      yellow_bold "Creating backup file: ${backup_dest}${item}.bak."
      cp -rf "$item" "${backup_dest}${item}.bak"
    else
      yellow_bold "Creating backup file: ${item}.bak."
      cp -rf "$item" "${item}.bak"
    fi
  fi
fi
