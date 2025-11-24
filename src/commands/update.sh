set -e

# shellcheck disable=SC2155
declare current_directory="$(pwd)"

return_to_previous_directory() {
  cd "$current_directory" || exit
}

trap 'return_to_previous_directory' EXIT

cyan "Updating the devtools script"

cd "$HOME/.local/share/devtools" || exit

spinny-start
git remote update
spinny-stop

if [[ $(git status -suno) ]]; then
  yellow_bold "There are changes present in the repo. Please commit then before updating."
else
  git pull
  cyan_bold "Devtools was updated! Refresh completions to finish update: 'source ~/.bashrc'"
fi
