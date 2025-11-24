filter_multiplot_requirements() {
  # shellcheck disable=SC2154
  if [[ "${args[--multiplot]}" == 1 ]]; then
    # shellcheck disable=SC2154
    if [[ "${args[--gui]}" != 1 ]]; then 
      red_bold "Multiplot can only be used in GUI mode. Add the '--gui' flag to plot multiple graphs" 
    fi

    if [[ "${args[--type]}" != "bar" ]]; then
      red_bold "Multiplot can only be used with bar graphs. Add the '--type bar' flag to enable bar graphs"
    fi
  fi
}

filter_stack_vertically_multiplot_only() {
  if [[ "${args[--stack-vertically]}" == 1 ]]; then
    if [[ "${args[--multiplot]}" != 1 ]]; then
      red_bold "The '--stack-vertically' flag can only be used with multiplot mode. Add the '--multiplot' flag to use '--stack-vertically'."
    fi
  fi
}
