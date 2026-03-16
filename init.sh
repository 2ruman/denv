#!/bin/bash

function exit_err() {
    if [ $? -ne 0 ]; then
        echo "Failed to set up your world"
        exit 1
    fi
}

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
exit_err

# Read Only 2ruman
RO2=/$U/.2ruman

mkdir $RO2
sudo chattr -a $RO2/
mv ~/dev-env/ $RO2/
cd $RO2/ && git clone https://github.com/2ruman/linux-programming.git

echo "Done"
