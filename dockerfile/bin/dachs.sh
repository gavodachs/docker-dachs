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

# get the name of the postgres container linked to this one
PG_ENV_ALIAS=$(env | grep "ENV_PG_VERSION" | cut -d"_" -f1)
PG_HOST=$(basename `env | grep "${PG_ENV_ALIAS}_NAME" | cut -d"=" -f2`)
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

gavo serve start
