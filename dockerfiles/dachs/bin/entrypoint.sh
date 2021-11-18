#!/bin/bash

# Decide what to do when dachs container starts.
#
# If the container is in a composition of containers, with postgres servicing it
# from another container, this container will run only Dachs server.
#
# If this container is running standalone, both servers, Dachs and Postgres,
# must be started.
#
# What to do will be told when the container start/run through the commands:
# - start: start both servers (dachs + postgres)
# - serve [dachs options]: start dachs only
# * If no initial command is given, just print 'help.sh'

if [ "$#" -eq 0 ]; then
  ./help.sh
else
  if [ "$1" = "start" ]; then
    ./dachs.sh $1
  else
    service postgresql status || service postgresql start
    dachs $@
  fi
fi

# Ah, ha, ha, ha, stayin' alive...
# while :; do :; done & kill -STOP $! && wait $!
