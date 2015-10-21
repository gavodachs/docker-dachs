#!/bin/bash

#supervisorctl start postgres dachs

service postgresql start 
# After starting Postgres, wait a little bit to have it fully running
sleep 30
# then DaCHS will have the proper environment to run
gavo serve debug
