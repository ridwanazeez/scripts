#!/bin/bash

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade

# Install and configure qemu-guest-agent
sudo apt-get install qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent

# Install git
sudo apt install git

# Install zsh and Oh My Zsh
sudo apt install zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
omz reload

# Download custom ssh_config
curl -O https://raw.githubusercontent.com/ridwanazeez/proxmox/master/setup_ubuntu/sshd_config

# Edit SSH configuration to allow SSH root login
ssh_config="/etc/ssh/sshd_config"
custom_config="sshd_config"

# Backup the original sshd_config file
sudo cp "$ssh_config" "$ssh_config.backup"

# Replace the contents of sshd_config with your custom configuration
sudo cat "$custom_config" > "$ssh_config"

# Restart sshd
sudo service ssh restart

# Remove custom SSH file since it's not needed anymore
rm sshd_config

# Remove Docker related packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove $pkg;
done

# Install Docker dependencies
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Run Portainer container
docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:2.19.4

# Run Watchtower container to auto-update other containers
docker run -d --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower

# Remove custom SSH file since it's not needed anymore
rm sshd_config