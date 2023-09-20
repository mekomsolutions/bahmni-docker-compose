#!/bin/bash
set +e
: ${1?"Usage: $1 restart-server.sh <project name>"}
cd /var/docker-volumes/bahmni/$1/bahmni_docker/
/usr/local/bin/docker-compose -p $1 --env-file=/var/docker-volumes/bahmni/$1/$1.env restart
exit 0