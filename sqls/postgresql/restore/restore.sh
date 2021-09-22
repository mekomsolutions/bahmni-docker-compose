#!/usr/bin/env bash

set -eu

ODOO_BACKUP_FILE=/opt/restore/odoo.tar

function create_user() {
	local user=$1
	local password=$2
	echo "  Creating '$user' user..."
	PGPASSWORD=$POSTGRES_PASSWORD psql -h postgresql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" $POSTGRES_DB <<-EOSQL
		CREATE DATABASE odoo;
		GRANT ALL PRIVILEGES ON DATABASE odoo TO $user;
EOSQL
}

if [ -f "$ODOO_BACKUP_FILE" ]; then
	create_user ${ODOO_DB_USER} ${ODOO_DB_PASSWORD}
	echo "importing..."
	set +e
	PGPASSWORD=$ODOO_DB_PASSWORD pg_restore -h postgresql -U ${ODOO_DB_USER} -d odoo < $ODOO_BACKUP_FILE
	PGPASSWORD=$POSTGRES_PASSWORD psql -h postgresql -U postgres -c "ALTER DATABASE odoo OWNER TO ${ODOO_DB_USER};"
fi

echo "Success."

OPENELIS_BACKUP_FILE=/opt/restore/clinlims.tar

function create_openelis_database() {
	local database=$1
	local user=$2
	local password=$3
	echo "  Creating 'OpenELIS' user and database..."
	PGPASSWORD=$POSTGRES_PASSWORD psql -h postgresql -v ON_ERROR_STOP=1 --username postgres postgres <<-EOSQL
	    DROP DATABASE $database;
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
}

if [ -f "$OPENELIS_BACKUP_FILE" ]; then
	create_openelis_database ${OPENELIS_DB_NAME} ${OPENELIS_DB_USER} ${OPENELIS_DB_PASSWORD}
    set +e
	echo "Import dump file"
	PGPASSWORD=$OPENELIS_DB_PASSWORD pg_restore -h postgresql -U ${OPENELIS_DB_USER} -d ${OPENELIS_DB_NAME} < $OPENELIS_BACKUP_FILE
	PGPASSWORD=$OPENELIS_DB_PASSWORD psql -h postgresql -U postgres -c "ALTER DATABASE ${OPENELIS_DB_NAME} OWNER TO ${OPENELIS_DB_USER};"
fi

echo "Success."