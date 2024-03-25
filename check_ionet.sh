#!/bin/bash

device_id="Yours device_id"
user_id="Yours user_id"
device_name="Yours device_name"
system=linux #linux or mac
gpu=false #false or true
if [[ "$system" == "linux" ]]; then
    os="Linux"
elif [[ "$system" == "mac" ]]; then
    os="macOS"
fi
if [[ $(docker ps | grep -c "io-worker-monitor") -eq 1 && $(docker ps | grep -c "io-worker-vc") -eq 1 ]]; then
    echo "NODE IS WORKING"
else
    echo "STOP AND DELETE ALL CONTAINERS"
    docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q) 
    yes | docker system prune -a
    echo "DOWNLOAD FILES FOR $os"
    rm -rf launch_binary_$system && rm -rf ionet_device_cache.txt
    curl -L https://github.com/ionet-official/io_launch_binaries/raw/main/launch_binary_$system -o launch_binary_$system
    chmod +x launch_binary_$system
    echo "START NEW NODE"
    /root/launch_binary_$system --device_id=$device_id --user_id=$user_id --operating_system="$os" --usegpus=$gpu --device_name=$device_name
fi
