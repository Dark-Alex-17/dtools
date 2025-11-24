detect_os() {
  case "$OSTYPE" in
    solaris*) echo "solaris"  ;;
    darwin*)  echo "macos"  ;;
    linux*)   echo "linux"  ;;
    bsd*)     echo "bsd"  ;;
    msys*)    echo "windows"  ;;
    cygwin*)  echo "windows"  ;;
    *)        echo "unknown"  ;;
  esac
}

get_opener() {
  declare cmd

  case "$(detect_os)" in
    macos)  cmd="open"  ;;
    linux)   cmd="xdg-open"  ;;
    windows) cmd="start"  ;;
    *)       cmd=""  ;;
  esac

  echo "$cmd"
}

open_link() {
  cmd="$(get_opener)"

  if [[ "$cmd" == "" ]]; then
    error "Your platform is not supported for opening links."
    red "Please open the following URL in your preferred browser:"
    red " ${1}"
    return 1
  fi

  $cmd "$1"

  if [[ $? -eq 1 ]]; then
    error "Failed to open your browser."
    red "Please open the following URL in your browser:"
    red "${1}"
    return 1
  fi

  return 0
}
