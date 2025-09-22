#!/usr/bin/env bash

# The hostname or IP of the host to which this script will attempt 
# to login and start triggering alerts
TARGET_HOST='' 

# Base directory from which all of these alert triggers will be 
#run on the target host
ROOTDIR='' 

# The user account on the TARGET_HOST
SSH_USER='' 

# List of required variables
required_vars=(
  TARGET_HOST
  ROOTDIR
  SSH_USER
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

ssh $SSH_USER@$TARGET_HOST "/usr/bin/find . -exec /bin/sh -c $ROOTDIR/scripts/exfill.sh \; -quit"

ping $TARGET_HOST