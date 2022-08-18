# Bahmni Docker Compose

Docker Compose project to run Bahmni.

<p align="left">
  <img src="./readme/bahmni-logo-square.png" alt="Bahmni Logo" height="155">
  <img src="./readme/plus.png" alt="plus sign" height="50">
  <img src="./readme/vertical-logo-monochromatic.png" alt="Docker Logo" height="150">
  </p>

## Quick Start

### Create your working directory:

Move to the location of your choice, eg, your home folder:
```
cd ~/
```
Then create the working directory and save the path:
```
export BAHMNI_DIR=$PWD/bahmni && \
mkdir $BAHMNI_DIR
```

### Download the Docker Compose project itself:

```
export VERSION=2.0.0-SNAPSHOT && \
# Download the project && \
mvn org.apache.maven.plugins:maven-dependency-plugin:3.2.0:get -DremoteRepositories=https://nexus.mekomsolutions.net/repository/maven-public -Dartifact=net.mekomsolutions:bahmni-docker-compose:$VERSION:zip -Dtransitive=false --legacy-local-repository && \
# Unzip the project in $BAHMNI_DIR/bahmni-docker-compose-$VERSION && \
mvn org.apache.maven.plugins:maven-dependency-plugin:3.2.0:unpack -Dproject.basedir=$BAHMNI_DIR -Dartifact=net.mekomsolutions:bahmni-docker-compose:$VERSION:zip -DoutputDirectory=$BAHMNI_DIR/bahmni-docker-compose-$VERSION
```

### Download the Bahmni distribution of your choice:

The Docker images do not provide a default Bahmni distribution so you need to first fetch one.

Fetch the distribution of your choice:

Eg, Bahmni Distro **Haiti**:
```
export DISTRO_GROUP="haiti" && \
export DISTRO_VERSION="1.2.0-SNAPSHOT" && \
# Download the distro && \
mvn org.apache.maven.plugins:maven-dependency-plugin:3.2.0:get -DremoteRepositories=https://nexus.mekomsolutions.net/repository/maven-public -Dartifact=net.mekomsolutions:bahmni-distro-$DISTRO_GROUP:$DISTRO_VERSION:zip -Dtransitive=false --legacy-local-repository && \
# Unzip the distro in $BAHMNI_DIR/bahmni-distro-$DISTRO_GROUP-$DISTRO_VERSION && \
mvn org.apache.maven.plugins:maven-dependency-plugin:3.2.0:unpack -Dproject.basedir=$BAHMNI_DIR -Dartifact=net.mekomsolutions:bahmni-distro-$DISTRO_GROUP:$DISTRO_VERSION:zip -DoutputDirectory=$BAHMNI_DIR/bahmni-distro-$DISTRO_GROUP-$DISTRO_VERSION
```


The Bahmni Docker project relies on environment variable to document where the Distro is to be found.
As an example, you can export the following variables:
```
export DISTRO_PATH=$BAHMNI_DIR/bahmni-distro-$DISTRO_GROUP-$DISTRO_VERSION && \
export OPENMRS_CONFIG_PATH=$DISTRO_PATH/openmrs_config && \
export BAHMNI_CONFIG_PATH=$DISTRO_PATH/bahmni_config && \
export OPENMRS_MODULES_PATH=$DISTRO_PATH/openmrs_modules && \
export BAHMNI_APPS_PATH=$DISTRO_PATH/bahmni_emr/bahmniapps && \
export ODOO_CONFIG_PATH=$DISTRO_PATH/odoo_config && \
export ODOO_EXTRA_ADDONS=$DISTRO_PATH/odoo_addons && \
export EIP_CONFIG_PATH=$DISTRO_PATH/eip_config
```

The complete list of available variables can be found in [.env](.env).

### Start Bahmni:

```
cd $BAHMNI_DIR/bahmni-docker-compose-$VERSION && \
docker-compose -p $DISTRO_GROUP up
```
<p align="center">
<img src="./readme/docker-compose-up-shadow.png" alt="docker-compose up" height="200">
</p>

**Important:** This assumes that you run the `docker` command as the same user and in the same window in which you exported your variables.
If Docker is run as `sudo`, the variables won't have an effect. Make sure to either export them as root, or run `docker` with `sudo -E` option to preserve the user environment. See [Docker on Linux Post-install steps](https://docs.docker.com/engine/install/linux-postinstall/)

### Access the servers:

- Bahmni: http://localhost/

<p align="left">
<img src="./readme/bahmni-EMR-login-shadow.png" alt="Bahmni EMR login screen" width="300">
</p>


- OpenMRS: http://localhost/openmrs

<ins>Default credentials</ins>:
  - username: superman
  - password: Admin123

<p align="left">
<img src="./readme/openmrs-login-shadow.png" alt="OpenMRS login screen" width="300">
</p>

- Odoo: http://localhost:8069/

<ins>Default credentials</ins>:
  - username: admin
  - password: admin

<p align="left">
<img src="./readme/odoo-login.png" alt="Odoo login screen" width="300">
</p>

- Metabase: http://localhost:9003/

<ins>Default credentials</ins>:
  - username: admin@metabase.local
  - password: Metapass123

<p align="left">
<img src="./readme/metabase-login.png" alt="Metabase login screen" width="300">
</p>

- OpenELIS: http://localhost/openelis

<ins>Default credentials</ins>:
  - username: admin
  - password: adminADMIN!

<p align="left">
<img src="./readme/openelis-login.png" alt="OpenELIS login screen" width="300">
</p>

## Advanced

### TLS support

To enable TLS support, just export the variable:

```
export PROXY_TLS="-DenableTLS"
```
and restart the application.

Default certificates are self-signed and therefore unsecured.

Provide your own valid certificates as a bound volume mounted at `/etc/tls/`.


### Start from a backup file

To run a fresh system based on a production backup file (see [here](https://github.com/mekomsolutions/appliance-deployment/blob/main/README.md#backup-profile) for more details) follow these steps:

1. Unzip the backup file and rename PostgreSQL database files to **<database>.tar**:
  Eg:
  - OpenELIS : **clinlims.tar**
  - Odoo : **odoo.tar**
2. Move PostgreSQL database files to [./sqls/postgresql/restore](./sqls/postgresql/restore) folder
3. For OpenMRS database please follow the steps [here](#start-with-a-custom-mysql-dump)
4. Unzip the **filestore.zip** file and set the variables in **.env** file as following:
  Example for a K8s-made backup:
   - Odoo:
     - `ODOO_FILESTORE=<filestore-path>/odoo/filestore/odoo`
   - OpenMRS:
     - `OPENMRS_LUCENE_PATH=<filestore-path>/openmrs/lucene`
     - `OPENMRS_ACTIVEMQ_PATH=<filestore-path>/openmrs/activemq-data`
     - `OPENMRS_CONFIG_CHECKSUMS_PATH=<filestore-path>/openmrs/configuration_checksums`
     - `BAHMNI_HOME_PATH=<filestore-path>/openmrs/bahmni`

Note: `<filestore-path>` is the path of the folder where **filestore.zip** file was unzipped.

5. Start PostgreSQL:

```
docker-compose [-p <project-name>] up -d postgresql
```

6. Start the restore service

```
docker-compose [-p <project-name>] -f postgres_restore.yml up
```


Now the restore is done, you can turn off postgresql by
```
docker-compose [-p <project-name>] stop postgresql
```
or simply start Bahmni as described [here](#start-bahmni)

### Start with a custom MySQL dump

To start OpenMRS with your own database, just drop your data file (`.sql` or `.sql.gz`) in the [./sqls/mysql/](./sqls/mysql/) folder and recreate your volumes (`docker-compose -v down`).

### Disable individual services
If you are developing, you may not want to run the complete Bahmni suite.
You can disable services by adding **docker-compose.override.yml** file at the project root with the following contents:

**./docker-compose.override.yml**
```
#
# Example file to disable docker-compose.yml services.
#
version: "3.7"

services:
  odoo:
    entrypoint: ["echo", "[ERROR] Service is disabled in docker-compose.override.yml file"]
  postgresql:
    entrypoint: ["echo", "[ERROR] Service is disabled in docker-compose.override.yml file"]
```

You can also of course comment the services directly in the [docker-compose.yml](./docker-compose.yml) file.

### Develop in Bahmn Apps

Bahmni Docker project can be used to setup a dev environment for Bahmni. This is especially easy when working on Bahmni Apps.


This can be done by using `watch rsync ...` command to see your changes on the running server.
1. Clone and build Bahmni Apps locally:
```
cd ~/repos
git clone https://github.com/Bahmni/openmrs-module-bahmniapps.git
cd openmrs-module-bahmniapps/ui
```
Change JS and HTML files as you like.

2. Run the `watch rsync` command to override the server files: (using `watch` makes it run every 2 seconds)
```
watch rsync -av ~/repos/openmrs-module-bahmniapps/ui/ /tmp/bahmni-distro-haiti/bahmni_emr/bahmniapps/
```

### Debug the Java apps

The Java apps (OpenMRS, Bahmni Reports, Odoo Connect...) can be remote debugged very simply by setting a the `DEBUG: "true"` environment variable to the service.

Don't forget to open the port `8000` on the service as well:
Eg:
```
...
environment:
  DEBUG: "true"
...

ports:
  - 8000:8000
...
```

### Provide additional properties files to OpenMRS (including runtime properties)

In order to provide additional properties files to openmrs, you can drop your file in the [./properties/openmrs/](./properties/openmrs/) folder.

Files will be made available in the application directory after a convenient environment variable substitution is applied.

Special case of _runtime properties_:

In order to provide additional runtime properties to OpenMRS, you can drop a file that is named such as `<name>-runtime.properties`.
It will be handled differently than the other properties files to be merged to the existing **openmrs-runtime.properties**

For instance:


Create a file named `initializer-runtime.properties` in **properties/openmrs/**, with following contents:
```
initializer.exclude.locations=*void_h1*
```

This will be added to the openmrs-runtime.properties file.

### All environment variables

The complete list of available variables can be found in [.env](.env).

## Dependencies

- Docker
- Docker Compose
- Maven

## Known limitations

- Supported components:
  - OpenMRS
  - Bahmni Apps
  - Bahmni Config
  - Bahmni Mart
  - Metabase
  - Odoo 14 (Odoo 10 supported on branch 1.x using Odoo Connect)
  - OpenELIS
