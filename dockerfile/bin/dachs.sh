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

service postgresql start 
