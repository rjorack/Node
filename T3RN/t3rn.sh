#!/bin/bash

source path/to/logo.sh
show_logo
cd $HOME
rm -rf executor
sudo apt -q update && sudo apt -qy upgrade

curl -L -o executor.tar.gz https://github.com/t3rn/executor-release/releases/download/v0.21.1/executor-linux-v0.21.1.tar.gz
tar -xzvf executor.tar.gz && cd executor/executor/bin

NODE_ENV="testnet"
LOG_LEVEL="debug"
LOG_PRETTY="false"
ENABLED_NETWORKS="arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn"

read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
export NODE_ENV LOG_LEVEL LOG_PRETTY ENABLED_NETWORKS PRIVATE_KEY_LOCAL

./executor
