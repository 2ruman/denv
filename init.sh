#!/bin/bash

U="truman"

if [ $USER != "$U" ]; then
    echo "Unexpected user... $USER"
    # If you want to initialize with another name, 
    # modify $U and comment out the next line
    exit 1 
fi

set -x

mkdir $HOME/world

sudo mkdir /$U
sudo chown $USER:$USER /$U

sudo -E env "U=$U" "HOME=$HOME" sh -c '(grep -q "Truman-added" /etc/fstab && echo "Already applied") ||
(printf "\n# Truman-added\n$HOME/world\t/$U\tnone\tdefaults,bind\t0\t0\n" >> /etc/fstab && echo "Done")'

sudo mount -a && sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "Failed to set up your world"
    exit 1
fi

echo "Done"
