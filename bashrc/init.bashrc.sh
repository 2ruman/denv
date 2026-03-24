#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/bashrc.func

BASHRC_FILE="$HOME/.bashrc"
KEYWORD="esac"
BKU_EXT=".bak"

U="truman"
NAME="${U^}"
STX="# $NAME >> "
ETX="# $NAME << "
BODY=$(cat << EOF
${STX}--------------------------------------------------------------------

source /${U}/denv/bashrc/init.rc
source /${U}/denv/bashrc/bashrc.alias

${ETX}--------------------------------------------------------------------
EOF
)
SAFE_BODY=${BODY//$'\n'/\\n}

if grep -q "$STX" "$BASHRC_FILE"; then
    _brc_log "STX matched"
    sed -i.bak "/$STX/,/$ETX/ {
        /$STX/s|.*|$SAFE_BODY|
        //!d
    }" "$BASHRC_FILE"
else
    _brc_log "STX not matched..."
    sed -i.bak "0,/esac/s||&\n\n$SAFE_BODY|" $BASHRC_FILE
fi

_brc_log "Done"

diff "$BASHRC_FILE" "$BASHRC_FILE.bak"

