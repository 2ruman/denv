#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_DIR}/utils/cui_utils.sh
source ${SCRIPT_DIR}/utils/futils.sh

VERSION=$(ext_ver_mmp_fn "$0")
PLATFORM=linux_amd64

if [ -f /usr/local/bin/yq ]; then
    log_warn "yq is found at /usr/local/bin"
    log_step "Checking version..."
    log_dent "$(/usr/local/bin/yq --version | head -n 1)"; echo
    pause2re
fi

if [ -n "$VERSION" ]; then
    VERSION="v${VERSION}"
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_${PLATFORM} -O /usr/local/bin/yq &&\
        sudo chmod +x /usr/local/bin/yq
else
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_${PLATFORM} -O /usr/local/bin/yq &&\
        sudo chmod +x /usr/local/bin/yq
fi

