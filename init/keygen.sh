#!/usr/bin/env bash

set -e

SSH_DIR="$HOME/.ssh"

KEY_TYPES=(
    "id_ed25519"
    "id_rsa"
)

EXISTING_KEY=""

if [[ -d "$SSH_DIR" ]]; then
    for key in "${KEY_TYPES[@]}"; do
        PRIVATE_KEY="$SSH_DIR/$key"
        PUBLIC_KEY="$PRIVATE_KEY.pub"
    
        if [[ -f "$PRIVATE_KEY" && -f "$PUBLIC_KEY" ]]; then
            EXISTING_KEY="$PRIVATE_KEY"
            break
        fi
    done
fi

if [[ -n "$EXISTING_KEY" ]]; then
    echo
    echo "Existing SSH key pair found:"
    echo "  Private key: $EXISTING_KEY"
    echo "  Public key : $EXISTING_KEY.pub"
    echo
    echo "Aborting key generation..."
    exit 0
fi

KEY_FILE="$SSH_DIR/id_ed25519"

echo
echo "No existing SSH key pair found."
echo "Generating ED25519 key pair..."
echo

if [[ -e "$KEY_FILE" || -e "$KEY_FILE.pub" ]]; then
    echo "ERROR: SSH key path already exists:"
    echo "  $KEY_FILE"
    echo "  $KEY_FILE.pub"
    exit 1
fi

if ! ssh-keygen \
    -t ed25519 \
    -f "$KEY_FILE"
then
    echo "ERROR: ssh-keygen failed."
    exit 1
fi

echo "SSH key generated:"
echo "  Private key: $KEY_FILE"
echo "  Public key : $KEY_FILE.pub"
echo
echo "Done"
