#!/bin/sh

## RUN USING 'sh -x matomo-backup.sh 2>&1 | tee debug.txt' to get DEBUG OUTPUT AND LOG

##############################################################################################################################
##                                          PLEASE SET ALL THE OPTIONS BELOW                                                ##
##                      PLEASE SET UP SSH KEYS WITH CONFIG BEFORE ATTEMPTING REMOTE BACKUP                                  ##
##  http://dieskim.me/2015/05/13/how-to-linux-ssh-key-password-free-automatic-config-authentication-backup-sftp-scp/

## REQUIREMENTS
#1. Install Matomo ExtraTools Plugin -> https://github.com/dieskim/extratools
#2. Make sure to run -> composer require symfony/yaml:~2.6.0 / composer require symfony/process:^3.4


## SET REMOTE BACKUP TRUE OR FALSE - DEFAULTS TO LOCALBACKUP
REMOTEBACKUP=false

## SET REMOTESERVER INFO IF USING REMOTE BACKUP - REMEMBER TO FIRST ENABLE SSH KEYS AS IN THE GUIDE ABOVE
REMOTESERVER=backup-server-nickname

## SET REMOVEDEST
REMOTEDEST=/home/backup-user/matomo-backup

## SET LOCAL DEST - SCRIPT DEFAULTS TO MOVING TAR TO LOCAL DESTINATION
LOCALDEST=/home/yourdest/matomo-backup/

## ROTATE BACKUP TRUE OR FALSE
ROTATEBACKUP=false

## SET KEEPDAYS IF USING ROTATEBACKUP - X AMOUNT OF DAYS BEFORE ROTATING
KEEPDAYS=7

## SET COUNLY BACKUP SCRIPT ROOT - BACKUP LOG CREATED HERE
BACKUPROOT=/var/matomo-backup

## SET BACKUP DIR/TAR NAME
BACKUPDIRVAR=hostname-matomo-backup

## SET MATOMO DIR
MATOMODIR=/var/matomo

##############################################################################################################################
##                              DO NOT EDIT FROM HERE - EXCEPT IF YOU KNOW WHAT YOU ARE DOING                               ##

## SET DATE 
DATE=`date +%Y-%m-%d`

## START IF ROTATEBACKUP
if $ROTATEBACKUP
then
	BACKUPDIR=$BACKUPDIRVAR-$DATE
else
	BACKUPDIR=$BACKUPDIRVAR
fi
## END IF ROTATEBACKUP

## CREATE BACKUPROOT
mkdir -p $BACKUPROOT

## CREATE BACKUPDIR
mkdir -p $BACKUPROOT/$BACKUPDIR

## CHANGE TO DIR
cd $BACKUPROOT

## TAR MATOMO DIR
tar cfz $BACKUPROOT/$BACKUPDIR/matomo_dir.tar.gz $MATOMODIR

## RUN MATOMO DATABSE BACKUP
$MATOMODIR/console database:backup --backup-path=$BACKUPROOT/$BACKUPDIR --timeout=6000

## TAR THE WHOLE BACKUP DIR AND REMOVE DIR IF SUCCESSFUL
tar cfz $BACKUPROOT/$BACKUPDIR.tar.gz $BACKUPROOT/$BACKUPDIR && rm -R $BACKUPROOT/$BACKUPDIR

## START IF REMOTEBACKUP ELSE LOCALBACKUP
if $REMOTEBACKUP;
then
## SEND TAR TO REMOTE SERVER
sftp $REMOTESERVER <<_EOF_
    put $BACKUPROOT/$BACKUPDIR.tar.gz $REMOTEDEST/$BACKUPDIR.tar.gz
    bye
_EOF_

    ## START IF ROTATEBACKUP REMOVE OLD
    if $ROTATEBACKUP
    then
ssh -T $REMOTESERVER <<_EOF_
    find $REMOTEDEST/$BACKUPDIR-* -mtime +$KEEPDAYS -exec rm -v {} \; | tee -a $REMOTEDEST/matomo-backup.log
    exit
_EOF_
    fi
    ## END IF ROTATEBACKUP REMOVE OLD

    ## REMOVE LOCAL TAR
    rm -v $BACKUPROOT/$BACKUPDIR.tar.gz | tee -a $BACKUPROOT/matomo-backup.log
else

    ## MAKE LOCALDEST
    mkdir -p $LOCALDEST

    ## MOVE TAR TO LOCALDEST
    mv -v $BACKUPROOT/$BACKUPDIR.tar.gz $LOCALDEST | tee -a $BACKUPROOT/matomo-backup.log

    ## START IF ROTATEBACKUP REMOVE OLD
    if $ROTATEBACKUP
    then
        find $LOCALDEST/$BACKUPDIR-* -mtime +$KEEPDAYS -exec rm -v {} \; | tee -a $BACKUPROOT/matomo-backup.log
    fi
    ## END IF ROTATEBACKUP REMOVE OLD
fi
## END IF REMOTEBACKUP ELSE LOCALBACKUP
