filter_debian_based_os() {
	if grep -qiv '^ID_LIKE=.*debian' /etc/os-release; then
      red_bold "This command can only be run on debian-based systems."
  fi
}