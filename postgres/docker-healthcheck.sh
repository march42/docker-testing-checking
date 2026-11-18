#!/bin/sh
### pg_healthcheck.sh

# /usr/local/bin/pg_isready checks the readiness of the postgresql instance
# ${POSTGRES_DB:+--dbname=${POSTGRES_DB}} checks environment variable POSTGRES_DB
#   to be defined `:+` and adds --dbname=${POSTGRES_DB} instead
# ${POSTGRES_USER_FILE:+--username=$(cat ${POSTGRES_USER_FILE})}
#   add --username=$(cat ${POSTGRES_USER_FILE}) if POSTGRES_USER_FILE defined
#   adds the files content to the parameter
# ${POSTGRES_USER:+--username=${POSTGRES_USER}}
#   adds --username=${POSTGRES_USER} if env var is defined
/usr/local/bin/pg_isready \
	${POSTGRES_DB:+--dbname=${POSTGRES_DB}} \
	${POSTGRES_USER_FILE:+--username=$(cat ${POSTGRES_USER_FILE})} \
	${POSTGRES_USER:+--username=${POSTGRES_USER}} \
	$*
exit $?
