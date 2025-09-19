#!/bin/bash
TARGET_HOST=''
HOMEDIR=''
SSH_USER=''

#ssh ericcobb@$HOST '/home/ericcobb/scripts/exfill_demo.sh'
ssh $SSH_USER@$TARGET_HOST "/usr/bin/find . -exec /bin/sh -c $HOMEDIR/scripts/exfill.sh \; -quit"

ping $TARGET_HOST