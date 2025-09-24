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
  TARGET_HOST_SSH_KEY
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

# Ensure an SSH agent is running
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null
fi
# Load SSH key
ssh-add $TARGET_HOST_SSH_KEY >/dev/null 2>&1

# Copy the files to the target host IF AND ONLY IF the destination directory does not already exist
# Check if the destination directory already exists and fail if it does
/bin/echo -n "Checking if $TARGET_HOST:$TARGET_HOST_ROOTDIR exists..."
ssh "$TARGET_HOST_SSH_USER@$TARGET_HOST" "DEST=$(printf %q "$TARGET_HOST_ROOTDIR"); 
  if mkdir \"\$DEST\" 2>/dev/null; then exit 0;
  elif [ -d \"\$DEST\" ]; then exit 17;
  else echo 'cannot create dest' >&2; exit 1; fi"

exit_code=$?
if [ "$exit_code" -eq 17 ]; then
  printf '\033[1;31mYes - Refusing to copy\033[0m\n' >&2
  exit 1
elif [ "$exit_code" -ne 0 ]; then
  printf 'Remote prep failed (rc=%d) for %s:%s\n' "$exit_code" "$TARGET_HOST" "$TARGET_HOST_ROOTDIR" >&2
  exit 1
fi

printf '\033[1;32mNo\033[0m\n'
/bin/echo -n "Copying files to $TARGET_HOST:$TARGET_HOST_ROOTDIR..."
tar --no-xattrs -C .. -cf - -- src bin files response scripts/{config.sh,exfill.sh} | \
ssh $TARGET_HOST_SSH_USER@$TARGET_HOST \
"set -e; DEST=$(printf %q "$TARGET_HOST_ROOTDIR"); tar -xf - -C \"\$DEST\""

if [ $? -ne 0 ]; then
  # 'printf' is a shell built-in so this should work without path
  printf '\033[1;31mFailed\033[0m\n'
  exit 1
else
    printf '\033[1;32mDone\033[0m\n'
fi