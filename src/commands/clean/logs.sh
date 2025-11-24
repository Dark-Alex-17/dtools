blue_bold "Cleaning system logs..."

blue_bold "Vacuuming journal logs older than 3 days..."
sudo journalctl --vacuum-time 3d

blue_bold "Deleting archived logs..."
sudo find /var/log -type f -name '*.gz' -delete
sudo find /var/log -type f -name '*.1' -delete
