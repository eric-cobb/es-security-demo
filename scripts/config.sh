######################
## TARGET VARIABLES ##
######################
# The hostname or IP of the host to which this script will attempt
# to login and start triggering alerts
TARGET_HOST=''

# Base directory from which all of these alert triggers
# will be run on the target host
TARGET_HOST_ROOTDIR=''

# The user SSH account on the TARGET_HOST that the demo_start.sh
# script will use to ssh into the TARGET_HOST from the local machine
TARGET_HOST_SSH_USER=''


######################
## EXFILL VARIABLES ##
######################
# The host that the scp command will attempt to "exfill" the data to
EXFILL_TARGET=''

# The user SSH account on the EXFILL_TARGET
EXFILL_SSH_USER=''

# The user account SSH private key on the TARGET_HOST that will
# be used to scp the 'exfill' data to the EXFILL_TARGET
EXFILL_SSH_KEY=''


#######################
##  LOCAL VARIABLES  ##
#######################
# The local machine private key; used by the demo_setup.sh and demo_start.sh 
# scripts on local machine to ssh into the TARGET_HOST
LOCAL_SSH_KEY=''

# Your home directory
#HOMEDIR=''

# This is the file that will be exfilled
FILE='/dev/shm/totally_not_exfill.tar.gz'
