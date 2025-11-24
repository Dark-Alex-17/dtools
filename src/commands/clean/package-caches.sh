blue_bold "Cleaning packages..."

blue_bold "Cleaning apt cache..."
sudo apt-get clean
sudo apt-get autoclean
blue_bold "Removing unnecessary apt dependencies..."
sudo apt-get autoremove
sudo apt-get purge

blue_bold "Cleaning up pip cache..."
pip cache purge 
sudo pip cache purge

if (command -v snap > /dev/null 2>&1); then
  blue_bold "Removing disabled snaps..."
  set -eu
  LANG=en_US.UTF-8 snap list --all |\
     awk '/disabled/{print $1, $3}' |\
     while read -r snapname revision; do
  		 snap remove "$snapname" --revision="$revision"
     done
   blue_bold "Purging cached Snap versions..."
   sudo rm -rf /var/cache/snapd/*
fi

green_bold "Finished cleaning packages"
