#!/usr/bin/env bash
set -e
current_dir=`pwd`
DISTRO_NAME=$1
DISTRO_VERSION=$2
distro_path=`mktemp -d -t $DISTRO_NAME-XXXXX`
./mvnw org.apache.maven.plugins:maven-dependency-plugin:3.2.0:get -DremoteRepositories=https://nexus.mekomsolutions.net/repository/maven-public -Dartifact=net.mekomsolutions:bahmni-distro-$DISTRO_NAME:$DISTRO_VERSION:zip -Dtransitive=false
./mvnw org.apache.maven.plugins:maven-dependency-plugin:3.2.0:unpack -Dmdep.overWriteReleases=true -Dmdep.overWriteSnapshots=true -Dartifact=net.mekomsolutions:bahmni-distro-c2c:1.2.0:zip -DoutputDirectory=$distro_path

export DISTRO_PATH=$distro_path && \
export OPENMRS_CONFIG_PATH=$DISTRO_PATH/openmrs_config && \
export BAHMNI_CONFIG_PATH=$DISTRO_PATH/bahmni_config && \
export OPENMRS_MODULES_PATH=$DISTRO_PATH/openmrs_modules && \
export BAHMNI_APPS_PATH=$DISTRO_PATH/bahmni_emr/bahmniapps && \
export ODOO_CONFIG_PATH=$DISTRO_PATH/odoo_config && \
export ODOO_EXTRA_ADDONS=$DISTRO_PATH/odoo_addons && \
export EIP_CONFIG_PATH=$DISTRO_PATH/eip_config

profile=`echo $RANDOM | md5sum | head -c 5; echo;`
docker-compose -p $profile up
