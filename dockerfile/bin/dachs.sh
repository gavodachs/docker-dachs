#!/bin/bash

echo ''
echo '================================================'
echo 'This the (main) DaCHS server container, where'
echo 'DaCHS daemon is meant to run.'
echo 'This container expects to use another container'
echo 'as the PostgreSQL databse server.'
echo ''
echo 'The Postgres container must be named *postgres*.'
echo 'Using the proper name will make the connection'
echo '"just work".'
echo ''
echo 'Apart from that restriction, DaCHS management'
echo 'proceed as usual (imp, pub, etc.).'
echo '================================================'
echo ''

# first, make sure the environment is initialised (can't do that
# at image build time since the postgres container is not available then)
su dachsroot -c "gavo init -d 'host=postgres dbname=gavo'"

su dachsroot -c "gavo serve debug"
