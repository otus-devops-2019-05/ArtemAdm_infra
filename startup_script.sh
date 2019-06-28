#!/bin/bash
# Add key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
# Add REPO
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
# Refresh APT
sudo apt update
#Install MongoDB-3.2
sudo apt install -y mongodb-org
# Start MongoDB
sudo systemctl start mongod
# Add autostart MongoDB service
sudo systemctl enable mongod
# Status Sevice
#sudo systemctl status mongod
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
#echo "Version Ruby:"
#ruby -v
#echo "Version Bundler:"
#bundler -v
# Clone
git clone -b monolith https://github.com/express42/reddit.git
# Install bundle
cd reddit
bundle install
# Start server
puma -d
# Test app
#ps aux | grep puma
