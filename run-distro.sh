#!/usr/bin/env bash
set -e
current_dir=`pwd`
DISTRO_NAME=$1
DISTRO_VERSION=$2
distro_path=$current_dir/target/$DISTRO_NAME
profile="$1-$2"
profile=`echo $profile | sed -r 's/[/.]+/_/g'`
docker_compose=""

if command -v docker-compose &> /dev/null; then
    docker_compose="docker-compose"
elif docker compose ps; then
    docker_compose="docker compose"
else
    echo "Docker Compose not found, aborting."
    exit
fi

echo "⚙️  Cleanup and prepare for distro run"
rm -rf $distro_path
$docker_compose -p $profile down -v

echo "⚙️  Fetching distro..."
./mvnw org.apache.maven.plugins:maven-dependency-plugin:3.2.0:get -DremoteRepositories=https://nexus.mekomsolutions.net/repository/maven-public -Dartifact=net.mekomsolutions:bahmni-distro-$DISTRO_NAME:$DISTRO_VERSION:zip -Dtransitive=false
./mvnw org.apache.maven.plugins:maven-dependency-plugin:3.2.0:unpack -Dmdep.overWriteReleases=true -Dmdep.overWriteSnapshots=true -Dartifact=net.mekomsolutions:bahmni-distro-$DISTRO_NAME:$DISTRO_VERSION:zip -DoutputDirectory=$distro_path

echo "⚙️ Starting distro..."
export DISTRO_PATH=$distro_path && \
export OPENMRS_CONFIG_PATH=$DISTRO_PATH/openmrs_config && \
export BAHMNI_CONFIG_PATH=$DISTRO_PATH/bahmni_config && \
export OPENMRS_MODULES_PATH=$DISTRO_PATH/openmrs_modules && \
export BAHMNI_APPS_PATH=$DISTRO_PATH/bahmni_emr/bahmniapps && \
export ODOO_CONFIG_PATH=$DISTRO_PATH/odoo_config && \
export ODOO_EXTRA_ADDONS=$DISTRO_PATH/odoo_addons && \
export EIP_CONFIG_PATH=$DISTRO_PATH/eip_config

$docker_compose -p $profile up
