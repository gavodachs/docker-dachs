#!/bin/bash

echo ''
echo '==================================================='
echo 'This is the PostgreSQL counterpart of DaCHS server.'
echo 'Unless you want to put your hands on the databse,'
echo 'you should be good to go and deal with the DaCHS'
echo 'server main conatiner itself.'
echo ''
echo 'To make use of this guy here, just make sure to'
echo 'run "dachs:server" with docker "--link" option'
echo 'pointing to this container here.'
echo '==================================================='
echo ''

export PGDATA=/var/lib/postgresql/${PG_VERSION}
# postgres needs this directory for log files; then start postgres
mkdir -p -m 777 /var/run/postgresql/${PG_VERSION}-main.pg_stat_tmp/
su - postgres  -c "/usr/lib/postgresql/${PG_VERSION}/bin/postgres \
	-c config_file=/etc/postgresql/${PG_VERSION}/main/postgresql.conf \
	-c logging_collector=on"
