#!/bin/bash

source $(realpath $(dirname "${BASH_SOURCE[0]}"))/inst.func

HTTPS_DEV_ANS_ADDR="https://developer.android.com/studio"
ANS_ARC_LINUX_URL_PTN="^[[:space:]]*href=\"https://.+android-studio-.+linux.tar.gz"

_get_dev_ans_addr() {
    echo "$HTTPS_DEV_ANS_ADDR"
}

_get_dev_ans_html() {
    wget -qO - $HTTPS_DEV_ANS_ADDR 2>/dev/null
}

_get_ans_arc_addr() {
    local -
    set -euo pipefail

    (_get_dev_ans_html | grep -oE $ANS_ARC_LINUX_URL_PTN | sed -E 's|^[[:space:]]*href="||') 2>/dev/null
}

_logo() {
    echo -e "${NOC}\
-------------------------------------------------------------------------
    ${GRN}"
cat << 'EOF'
     _              _           _     _   ____  _             _ _
    / \   _ __   __| |_ __ ___ (_) __| | / ___|| |_ _   _  __| (_) ___
   / _ \ | '_ \ / _` | '__/ _ \| |/ _` | \___ \| __| | | |/ _` | |/ _ \
  / ___ \| | | | (_| | | | (_) | | (_| |  ___) | |_| |_| | (_| | | (_) |
 /_/   \_\_| |_|\__,_|_|  \___/|_|\__,_| |____/ \__|\__,_|\__,_|_|\___/

 ___           _        _ _
 |_ _|_ __  ___| |_ __ _| | | ___ _ __
  | || '_ \/ __| __/ _` | | |/ _ \ '__|
  | || | | \__ \ || (_| | | |  __/ |
 |___|_| |_|___/\__\__,_|_|_|\___|_|

EOF
    echo -e "${NOC}\
-------------------------------------------------------------------------
    ${NOC}"
}

_logo

while getopts ":fi:d:" opt; do
    case $opt in
        f) i_mode=false ;;
        i) inst_dest=$OPTARG ;;
        d) dl_dest=$OPTARG ;;
        *) exit_err "Invalid option: -$OPTARG" ;;
        :) exit_err "Option -$OPTARG requires an argument" ;;
    esac
done
shift $(($OPTIND - 1))

i_mode=${i_mode:=true}
inst_dest=${inst_dest:=${MY_TOOLS:-}}
dl_dest="${dl_dest:=~/Downloads}/inst-ans"

[ -z "$inst_dest" ] && exit_err "Please provide directory to install or set \$MY_TOOLS variable beforehand"

log_mark "Download directory: ${YLW}${dl_dest}${NOC}"
log_mark "Installation directory: ${YLW}$inst_dest${NOC}"
[ $i_mode ] && ask_cnfm

log_step "Preparing download directory..."
[ ! -d "$dl_dest" ] && exit_of mkdir -p "$dl_dest"

log_step "Finding archive file on ${YLW}$(_get_dev_ans_addr)${NOC}"
arc_addr=$(_get_ans_arc_addr)
[ -z "$arc_addr" ] && exit_err "Archive file not found"

# log_step "Downloading archive file..."
arc_file=$(echo $arc_addr | sed -E 's/^.+\///')
[[ $? != 0 || -z $arc_file ]] && exit_err "Failed to get archive file name..."

log_mark "Archive file name: ${YLW}$arc_file${NOC}"
log_mark "Archive file destination: ${YLW}$dl_dest${NOC}"
log_over "Download will begin in 3 seconds..."
sleep 3s

log_step "Downloading archive file..."
wget -c -O "$dl_dest/$arc_file" "$arc_addr" || exit_err "Failed..."

log_step "Checking archive file..."
ans_dir_checked=$(tar -ztf "$dl_dest/$arc_file" | head -n1 | sed 's/\/$//')
[ -z "$ans_dir_checked" ] && exit_err "Cannot find directory in archive file"

log_mark "Directory in archive file: ${YLW}$ans_dir_checked${NOC}"


log_step "Checking destination directory..."
ans_tobe="$inst_dest/$ans_dir_checked"
ans_old="$inst_dest/${ans_dir_checked}.old"
if [ -e "$inst_dest/$ans_dir_checked" ]; then
    log_mark "Already exists: ${YLW}$ans_tobe${NOC}"
    log_step "Moving this to: ${YLW}$ans_old${NOC}"
    [ $i_mode ] && ask_cnfm

    [ -e "$ans_old" ] && exit_err "Already exists: ${YLW}$ans_old${NOC}"
    mv "$ans_tobe" "$ans_old"
fi

log_step "Decompressing archive file..."
ans_tobe="$inst_dest/$ans_dir_checked"
exit_of "tar -zxf $dl_dest/$arc_file -C $inst_dest/"

log_step "Removing archive file..."
rm_cmd="rm -rf $dl_dest"
log_mark "Prompting: ${YLW}$rm_cmd${NOC}"
[ $i_mode ] && ask_cnfm && exit_of "$rm_cmd"

log_mark "Done."
