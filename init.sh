#!/bin/bash
# Ubuntu

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update && sudo apt-get install -y --no-install-recommends --no-upgrade \
    iptables libnss3-tools ca-certificates sudo curl wget gnupg2 apt-utils zlib1g-dev autoconf build-essential git python-dev \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get update && sudo apt-get install -y --no-install-recommends --no-upgrade \
    google-chrome-stable \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

curl -sL https://deb.nodesource.com/setup_11.x | sudo bash -
sudo apt-get install -y --no-install-recommends --no-upgrade \
    nodejs \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

echo "setting up git credentials"
export GIT_CREDENTIALS=$(curl -s -H Metadata-Flavor:Google http://metadata/computeMetadata/v1/instance/attributes/creds)
if [[ ${GIT_CREDENTIALS} == *"Error 404"* ]];
then
    echo "no GIT_CREDENTIALS passed shutting down"
    sudo shutdown now
    exit 1
fi

if [[ ! -d /sfe ]]
then
    sudo mkdir /sfe
    sudo chmod 777 /sfe
fi

echo "${GIT_CREDENTIALS}" | sudo tee /sfe/git-credentials

sudo chmod 777 /sfe/git-credentials
sudo chattr +i /sfe/git-credentials

git config --global credential.helper "store --file=/sfe/git-credentials"

(git -C /sfe/proxy fetch --all && git -C /sfe/proxy reset --hard origin/mana-proxy) || (sudo rm -rf /sfe/proxy && mkdir /sfe/proxy && git -C /sfe clone --branch mana-proxy https://github.com/SymphonyOSF/proxy.git proxy)

/sfe/proxy/os_setup/startup.sh
