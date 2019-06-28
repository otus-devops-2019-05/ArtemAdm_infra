#!/bin/bash
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
echo "Version Ruby:"
ruby -v
echo "Version Bundler:"
bundler -v

