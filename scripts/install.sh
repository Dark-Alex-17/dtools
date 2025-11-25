#!/bin/bash
if ! [[ -L "$HOME/.local/bin/dtools" ]]; then
  wget -O "$HOME/.local/bin/dtools" "https://github.com/Dark-Alex-17/dtools/releases/latest/download/dtools"
fi

# shellcheck disable=SC2016
if ! ( grep 'eval "$(dtools completions)"' ~/.bashrc > /dev/null 2>&1 ); then
  echo 'eval "$(dtools completions)"' >> ~/.bashrc
fi
