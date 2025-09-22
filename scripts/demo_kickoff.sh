#!/bin/bash
TARGET_HOST='' # The hostname or IP of the host to which this script will attempt to login and start triggering alerts
ROOTDIR='' # Base directory from which all of these alert triggers will be run on the target host
SSH_USER='' # The user account on the TARGET_HOST

ssh $SSH_USER@$TARGET_HOST "/usr/bin/find . -exec /bin/sh -c $ROOTDIR/scripts/exfill.sh \; -quit"

ping $TARGET_HOST