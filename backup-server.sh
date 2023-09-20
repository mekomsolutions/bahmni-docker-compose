#!/bin/bash
set +e
: ${1?"Usage: $1 backup-server.sh <backup path> <project name>"}
: ${1?"Usage: $2 backup-server.sh <backup path> <project name>"}
export BACKUP_PATH=$2
export BACKUP_FOLDER=`date +%F-%R`
/usr/local/bin/docker-compose -f backup.docker-compose.yml -p $1 --env-file=/var/docker-volumes/bahmni/$1/$1.env up
exit 0