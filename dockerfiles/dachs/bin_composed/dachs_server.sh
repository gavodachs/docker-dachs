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
# Now, hard linked according to the docker compose
# The setup is described at https://dachs-doc.readthedocs.io/tutorial.html#two-server-operation

PG_HOST="${PG_NAME:-postgres}"

echo "Postgres Host (container name) is: $PG_HOST"

echo "Database name is gavo."

chown -R dachsroot:gavo ${GAVO_ROOT}

su dachsroot -c "gavo init -d 'host=${PG_HOST} dbname=gavo'"

dachs serve start

