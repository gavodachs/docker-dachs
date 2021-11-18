#!/bin/bash -e

dachs_run() {
  local SERVE="$1"

  case $SERVE in
    debug)
      service postgresql status || service postgresql start
      service dachs debug
    ;;
    start | run)
      service postgresql status || service postgresql start
      service dachs start
    ;;
    stop)
      service dachs stop
    ;;
    *)
      THIS=$(basename $BASH_SOURCE)
      echo ""
      echo "Usage: $THIS {start|stop|debug}"
      echo ""
      exit 1
    ;;
  esac
}

dachs_run $1
