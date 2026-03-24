#!/bin/bash

RED='\033[0;31m'    # Red
GRN='\033[0;32m'    # Green
NOC='\033[0m'       # No Color(=Reset)

log_step() { echo -e "${GRN}\U2192${NOC} ${*}"; }
log_erro() { echo -e "${RED}\U0021${NOC} ${*}"; }
exit_err() {
    [ $? -ne 0 ] && log_erro "Failed to init your world" && exit 1
}

U="truman"      # User Name
W="$HOME/world" # User World Path as a sole directory in home partition

if [ $USER != "$U" ]; then
    echo "Unexpected user... $USER"
    # If you want to initialize with another name,
    # modify $U and comment out the next line not to exit
    exit 1
fi

set -e

log_step "Setting user-root directory"
[ ! -d $W ] && mkdir $W
[ ! -d $U ] && sudo mkdir /$U && sudo chown $USER:$USER /$U

log_step "Checking mount status"
detected_mnt=$(findmnt -s "/$U")
[ -n "$detected_mnt" ] && echo -e "Detected mount status:\n" "$detected_mnt"

echo "$detected_mnt" | grep -qE "^/${U}\s+${W}.+"
mnt_status=$?

sudo -E env "U=$U" "W=$W" sh -c '(grep -q "Truman-added" /etc/fstab && echo "...Already applied") ||
(printf "\n# Truman-added\n${W}\t/${U}\tnone\tdefaults,bind\t0\t0\n" >> /etc/fstab && echo "Done")'

if [ "$mnt_status" -ne 0 ]; then
    log_step "Mounting user-root directory"
    sudo mount -a && sudo systemctl daemon-reload
fi

log_step "Moving dev-environment to user-root directory"
mv ~/denv/ /$U/

log_step "Preparing read-only 2ruman directory"
ROD=/$U/ro
RO2=$ROD/.2ruman
[ ! -d $RO2 ] && mkdir -p $RO2
sudo chattr -a $RO2/

REPO="linux-programming"
log_step "Cloning a repository for later utilization: $REPO"
cd $RO2/
if [ ! -d "$REPO" ]; then
    git clone https://github.com/2ruman/$REPO.git
else
    cd $REPO/
    git pull
fi

cd $ROD/
ln -s $RO2/$REPO/bash/tooling $ROD/tooling

echo "Done"
