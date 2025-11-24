filter_linux_image_url_or_dist_is_defined() {
  # shellcheck disable=SC2154
  declare dist="${args[--dist]}"
  # shellcheck disable=SC2154
  declare image_url="${args[--image-url]}"

  if [[ -z $image_url && -z $dist ]]; then
    red_bold "One of either '--image-url' or '--dist' is required"
  fi
}
