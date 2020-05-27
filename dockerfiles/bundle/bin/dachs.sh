#!/bin/bash -e

#ENV="env -i LANG=C PATH=/usr/local/bin:/usr/bin:/bin"
. /lib/lsb/init-functions
test -f /etc/default/rcS && . /etc/default/rcS
test -f /etc/default/apache2 && . /etc/default/apache2
#SERVER_BIN="$ENV /usr/bin/dachs --disable-spew serve"

SERVER_BIN="/usr/bin/dachs --disable-spew serve"

dachs_start() {
	MODE="$1"
	service postgresql status || service postgresql start
	$SERVER_BIN $MODE
}

case $1 in
	debug)
		log_daemon_msg "Starting VO server (debug)" "dachs"
		dachs_start debug && log_end_msg 0 || log_end_msg 1
	;;
	start)
		log_daemon_msg "Starting VO server" "dachs"
		dachs_start start && log_end_msg 0 || log_end_msg 1
		#if $SERVER_BIN start; then
		#	log_end_msg 0
		#else
		#	log_end_msg 1
		#fi
	;;
	stop)
		log_daemon_msg "Stopping VO server" "dachs"
		if $SERVER_BIN stop; then
			log_end_msg 0
		else
			log_end_msg 1
		fi
	;;
	reload | force-reload)
		log_daemon_msg "Reloading VO server config" "dachs"
		if $SERVER_BIN reload $2 ; then
			log_end_msg 0
		else
			log_end_msg 1
		fi
	;;
	restart)
		log_daemon_msg "Restarting VO server" "dachs"
		if $SERVER_BIN restart; then
			log_end_msg 0
		else
			log_end_msg 1
		fi
	;;
	*)
		log_success_msg "Usage: /etc/init.d/dachs {start|stop|debug|restart|reload|force-reload}"
		exit 1
	;;
esac
