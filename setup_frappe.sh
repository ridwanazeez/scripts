#!/bin/bash

# Default Variables
NODE_VERSION=18
OLD_NODE_VERSION=16
FRAPPE_BRANCH=version-15
MARIADB_ROOT_PASSWORD=123
ADMIN_PASSWORD=admin

# Prompt for the site name
read -p "Enter the site name (e.g., mysite.localhost): " SITE_NAME
if [ -z "$SITE_NAME" ]; then
    echo "Site name cannot be empty. Please run the script again and provide a valid site name."
    exit 1
fi

echo "Installing Node.js version $NODE_VERSION and setting it as default..."
nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use $NODE_VERSION && nvm uninstall $OLD_NODE_VERSION

echo "Installing npm and yarn globally..."
npm install -g npm && npm install -g yarn

echo "Initializing bench with Frappe branch $FRAPPE_BRANCH..."
bench init --skip-redis-config-generation --frappe-branch $FRAPPE_BRANCH frappe-bench --verbose

cd frappe-bench || exit
echo "Setting up MariaDB and Redis hosts..."
bench set-mariadb-host mariadb && \
bench set-redis-cache-host redis-cache:6379 && \
bench set-redis-queue-host redis-queue:6379 && \
bench set-redis-socketio-host redis-socketio:6379

echo "Creating a new site: $SITE_NAME..."
bench new-site $SITE_NAME \
    --mariadb-root-password $MARIADB_ROOT_PASSWORD \
    --admin-password $ADMIN_PASSWORD \
    --no-mariadb-socket \
    --verbose

bench use $SITE_NAME
bench set-config developer_mode 1
bench set-config -g server_script_enabled 1

echo "Setup completed for site $SITE_NAME on Frappe branch $FRAPPE_BRANCH."
