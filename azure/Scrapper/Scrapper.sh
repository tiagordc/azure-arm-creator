#!/bin/bash

ORCHESTRATPR_IP=$1
QUERY=$2
LANGUAGE=$3
MODEL_ADDRESS=$4
VM_INDEX=$5
INSTANCES=$6

apt update
apt-get install -y software-properties-common curl wget

# Get and build project
apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
apt-get install -y nodejs git
mkdir /var/lib/scrapper
cd /var/lib/scrapper
git clone https://github.com/tiagordc/web-image-scrapper.git .
npm install --unsafe-perm=true --allow-root

# Run
# node /var/lib/scrapper/index.js -o $ORCHESTRATPR_IP -q $QUERY -l $LANGUAGE -m $MODEL_ADDRESS
