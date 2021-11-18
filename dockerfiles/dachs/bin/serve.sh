#!/bin/bash

echo ''
echo '================================================'
echo 'This is the DaCHS server container,'
echo 'where DaCHS daemon runs.'
echo ''
echo 'This container expects to use another container'
echo 'as the PostgreSQL database server.'
echo 'This "expectation" is satisfied with Docker'
echo 'option --link <name-of-postgres-container>.'
echo ''
echo 'If something doesnt work as expected, issue-us:'
echo '- https://github.com/chbrandt/docker-dachs'
echo '================================================'
echo ''

# We want to now discover the name of the Postgres container to connect.
# To do that we have to sniff the environment variables, when containers
# link/compose environment variables are created the name of the linked
# container.
# E.g (with a compose where service is "postgres" and name is "dachs-postgres").
#
# root@95012d537482:/# env | sort
# DACHS_POSTGRES_ENV_LC_ALL=C.UTF-8
# DACHS_POSTGRES_ENV_PG_VERSION=11
# DACHS_POSTGRES_NAME=/dachs-server/dachs-postgres
# DACHS_POSTGRES_PORT=tcp://172.17.0.2:5432
# DACHS_POSTGRES_PORT_5432_TCP=tcp://172.17.0.2:5432
# DACHS_POSTGRES_PORT_5432_TCP_ADDR=172.17.0.2
# DACHS_POSTGRES_PORT_5432_TCP_PORT=5432
# DACHS_POSTGRES_PORT_5432_TCP_PROTO=tcp
# GAVOSETTINGS=/etc/gavo.rc
# GAVO_ROOT=/var/gavo
# HOME=/root
# HOSTNAME=95012d537482
# LC_ALL=C.UTF-8
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# PG_VERSION=11
# POSTGRES_ENV_LC_ALL=C.UTF-8
# POSTGRES_ENV_PG_VERSION=11
# POSTGRES_NAME=/dachs-server/postgres
# POSTGRES_PORT=tcp://172.17.0.2:5432
# POSTGRES_PORT_5432_TCP=tcp://172.17.0.2:5432
# POSTGRES_PORT_5432_TCP_ADDR=172.17.0.2
# POSTGRES_PORT_5432_TCP_PORT=5432
# POSTGRES_PORT_5432_TCP_PROTO=tcp
# PWD=/
# SHLVL=0
# TERM=xterm
# _=/usr/bin/env
#

# get the name of the postgres container linked to this one
# PG_ENV_ALIAS=$(env | grep "ENV_PG_VERSION" | cut -d"_" -f1)
_VARS=($(env | grep "ENV_PG_VERSION"))
_ALIAS=$(echo ${_VARS[0]} | cut -d"_" -f1)
_AUX="${_ALIAS}_NAME"
PG_HOST=$(basename `echo "${!_AUX}" | cut -d"=" -f2`)
export PG_HOST

# first, make sure the environment is initialised (can't do that
# at image build time since the postgres container is not available then)
echo -n "Waiting for postgres to come up..."
while ! su - dachsroot -c "psql -h ${PG_HOST} --quiet gavo -c 'SELECT 1' > /dev/null 2>&1"  ;
do
    sleep 5
    echo -n .
done
echo

su dachsroot -c "gavo init -d 'host=${PG_HOST} dbname=gavo'"

dachs serve start
