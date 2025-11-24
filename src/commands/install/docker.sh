blue_bold "Installing prerequisites..."
yes | sudo add-apt-repository universe
yes | sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release apt-transport-https

blue_bold "Checking for the /etc/apt/keyrings directory..."
[[ -d /etc/apt/keyrings ]] || sudo mkdir /etc/apt/keyrings

blue_bold "Installing the Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

blue_bold "Setting up the Docker APT repository..."
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo $VERSION_CODENAME)\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

blue_bold "Installing Docker..."
sudo apt-get install containerd.io docker-ce docker-ce-cli docker-compose-plugin docker-buildx-plugin

green_bold "Successfully installed Docker"
