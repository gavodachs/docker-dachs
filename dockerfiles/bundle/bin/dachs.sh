#!/bin/bash -e

dachs_start() {
	SERVE="$1"
}

case $1 in
	debug)
		service postgresql status || service postgresql start
		service dachs start --debug
	;;
	start)
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
