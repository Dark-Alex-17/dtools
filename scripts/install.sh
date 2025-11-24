#!/bin/bash
if ! [[ -L "$HOME/.local/bin/dtools" ]]; then
  sudo ln -s "$PWD/dtools" "$HOME/.local/bin/dtools"
fi

# shellcheck disable=SC2016
if ! ( grep 'eval "$(dtools completions)"' ~/.bashrc > /dev/null 2>&1 ); then
  echo 'eval "$(dtools completions)"' >> ~/.bashrc
fi
