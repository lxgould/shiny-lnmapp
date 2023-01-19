#!/bin/sh
#- =======================================================
#- NAME: install.sh
#- DESCRIPTION: Install the lnmapp shiny app
#- INPUT:
#- OTHER DEPENDENCIES:
#- AUTHOR: lg
#- DATE: 2023-01-19
#- =======================================================

#- Constants
ME=`basename $0`
CWD=`pwd`
ME_START=`date +"%Y%m%d_%T"`
CONFIG_DIR=
BIN_DIR=/usr/local/bin
INSTALLED_FROM=$CWD
INSTALL_TO=/srv/shiny-server/apps/prod/lnmApp
REPO="shiny-lnmapp"
APP=${INSTALLED_FROM}/app.R
R_DIR=${INSTALLED_FROM}/R
DATA_DIR=${INSTALLED_FROM}/data

#- List the required directories and files here
REQ_DIRS="$R_DIR $DATA_DIR ${INSTALLED_FROM}/renv"
REQ_FILES="$APP .Rprofile"

[ -r ${BIN_DIR}/time_func.sh ] && . ${BIN_DIR}/time_func.sh
[ -r ${BIN_DIR}/file_func.sh ] && . ${BIN_DIR}/file_func.sh
[ -r ${BIN_DIR}/mail_func.sh ] && . ${BIN_DIR}/mail_func.sh

printf "\n%-20s: %s\n" "PROGRAM BEGIN" $ME
printf "%s\n" '------------------------------------'
printf "%-20s: %s\n" "Date" "$ME_START"
printf "%-20s: %s\n" "PWD" "$CWD"
printf "%-20s: %s\n" "User" "$USER"
printf "%-20s: %s\n" "Host" "$HOSTNAME"
printf "%-20s: %s\n" "Repository Name" "$REPO"
printf "%-20s: %s\n" "Source Dir" "$INSTALLED_FROM"
check_dir "$INSTALLED_FROM" || exit
printf "%-20s: %s\n" "Install To Dir" "$INSTALL_TO"
check_dir "$INSTALL_TO" || exit
printf "%-20s: %s\n" "BIN Dir" "$BIN_DIR"
check_dir "$BIN_DIR" || exit

#- before we start, we need to make sure that the executing user has sudo access
# [ "$USER" != "root" ] && {
#     printf "\nERROR: This program must be executed by root. Execute with 'sudo install.sh'\n\n"
#     exit 9
# }

#- really we should already be in this directory since it is set as pwd
cd "$INSTALLED_FROM"

errorCount=0
#- Check to be sure the requisite directories exist
for D in $REQ_DIRS ; do
    printf "%-20s: %s\n" "Copying Folder" "$D"
    check_dir "$D" || {
        printf "ERROR: I can not find the %s folder.\n" "$D"
        printf "\tIt should be in the root directory of the %s repository with this %s script\n" "$REPO" "$ME"
        (( errorCount++ ))
        continue
    }
    cp -rp $D "${INSTALL_TO}/"
done

#- Check to be sure the requisite files exist
for F in $REQ_FILES ; do
    printf "%-20s: %s\n" "Copying File" "$F"
    check_file "$F" || {
        printf "ERROR: I can not find the %s file.\n" "$F"
        printf "\tIt should be in the root directory of the %s repository with this %s script\n" "$REPO" "$ME"
        (( errorCount++ ))
        continue
    }
    cp $F "${INSTALL_TO}/"
done

# printf "%-20s: %s\n" 'Changing Group Ownership' "$INSTALL_DIR"
# chgrp -R shiny "${INSTALL_TO}"
# chown -R shiny.shiny "${INSTALL_TO}"


#- Display files in the app directory so we can see if everything looks ok
printf "\nFolder Listing of %s\n" "$INSTALL_TO"
ls -l "$INSTALL_TO"

[ $errorCount -gt 0 ] && {
    printf "\nERRORS: %s completed with errors.  Please check the errors in the output above\n\n" "$ME"
}

printf "%s\n" '------------------------------------'
printf "\n%-20s: %s\n" "PROGRAM END" $ME
