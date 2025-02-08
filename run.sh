#!/bin/bash
# should be run as root!
echo "Welcome to the EsSelqm installation!";

if [ `id -u` -ne 0 ]
  then echo "Please run as root"
  exit
fi


while true; do
    read -p "
This script will attempt to perform a system update, install required dependencies, install and configure NGINX and a few other utilities.
It is expected to run on a new system **with no running instances of any these services**. Make sure you check the script before you continue. Then enter yes or no
" yn
    case $yn in
        [Yy]* ) echo "OK!"; break;;
        [Nn]* ) echo "Have a great day"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# update the system
echo "Updating the system"
apt-get update
apt-get upgrade -y
echo "System updated"

# Function to check and install a package
install_package() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Installing..."
        sudo apt update && sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Check and install nginx and python3
install_package nginx
install_package python3
install_package python3-pip

# Define path to requirements.txt
REQUIREMENTS_FILE="$(pwd)/backend/requirements.txt"

# Install required Python libraries if requirements.txt exists
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing required Python libraries..."
    pip3 install -r "$REQUIREMENTS_FILE"
else
    echo "Warning: $REQUIREMENTS_FILE not found. Skipping Python library installation."
fi

# Copy nginx configuration file
NGINX_CONF_SOURCE="$(pwd)/nginx/nginx.conf"
NGINX_CONF_DEST="/etc/nginx/sites-available/default"

if [ -f "$NGINX_CONF_SOURCE" ]; then
    echo "Copying $NGINX_CONF_SOURCE to $NGINX_CONF_DEST"
    cp "$NGINX_CONF_SOURCE" "$NGINX_CONF_DEST"
else
    echo "Error: $NGINX_CONF_SOURCE not found. Exiting."
    exit 1
fi

# Restart and enable nginx
echo "Restarting NGINX service"
systemctl restart nginx

echo "Enabling NGINX service to start on boot"
systemctl enable nginx

echo "NGINX configuration and setup complete"

