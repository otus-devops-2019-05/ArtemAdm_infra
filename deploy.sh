#!/bin/bash
# Clone
git clone -b monolith https://github.com/express42/reddit.git
# Install bundle
cd reddit
bundle install
# Start server
puma -d
# Test app
ps aux | grep puma
