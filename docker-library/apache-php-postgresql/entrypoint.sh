#!/bin/bash
log(){
	while read line ; do
		echo "`date '+%D %T'` $line"
	done
}

set -e
logfile=/home/LogFiles/entrypoint.log
test ! -f $logfile && mkdir -p /home/LogFiles && touch $logfile
exec > >(log | tee -ai $logfile)
exec 2>&1

set_var_if_null(){
	local varname="$1"
	if [ ! "${!varname:-}" ]; then
		export "$varname"="$2"
	fi
}

set -e

echo "Starting SSH ..."
service ssh start

test ! -d "$HTTPD_LOG_DIR" && echo "INFO: $HTTPD_LOG_DIR not found. creating ..." && mkdir -p "$HTTPD_LOG_DIR"
chown -R www-data:www-data $HTTPD_LOG_DIR
test ! -d "$APPHOME" && echo "INFO: $APPHOME not found. creating ..." && mkdir -p "$APPHOME"
chown -R www-data:www-data $APPHOME

echo "Starting Apache httpd -D FOREGROUND ..."
apachectl start -D FOREGROUND