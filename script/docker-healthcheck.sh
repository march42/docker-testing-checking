#!/bin/sh
### alpine image uses busybox

###
#	signal TRAP
trap "echo -e \"EXITting\"" EXIT
trap "echo -e \"caught sigHUP\" ; exit" HUP
trap "echo -e \"caught sigINT\" ; exit" INT
trap "echo -e \"caught sigTERM\" ; exit" TERM

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
#set -e

# get current uid/gid (id -g appuser give primary group gid, which ist appgroup)
APP_UID=$(/usr/bin/id -u appuser)
APP_GID=$(/usr/bin/id -g appuser)

# first we assume everyting is peachy
returnCode=0

# check appuser/appgroup
if [[ "${HOST_GID:=${PGID}}" != "${APP_GID}" || "${HOST_UID:=${PUID}}" != "${APP_UID}" ]]; then
	[ -n "${IMG_DEBUG}" ] && echo -e "appuser is: $(/usr/bin/id appuser)"
	returnCode=1
fi
[ -n "${IMG_DEBUG}" ] && echo "running as: $(/usr/bin/id)"

# TLS settings
# i don't like SSL_CERT_FILE variable, for the misleading name
#[[ -n "${TLS_CA_FILE}" ]]	&& SSL_CERT_FILE=${TLS_CA_FILE}
# curl has it's own
[[ -n "${TLS_CA_FILE}" ]]	&& CURL_CA_BUNDLE=${TLS_CA_FILE}
# python has REQUESTS_CA_BUNDLE, but with what modules
#[[ -n "${TLS_CA_FILE}" ]]	&& REQUESTS_CA_BUNDLE=${TLS_CA_FILE}

# check networking
test_nameserver() {
	target=${1:--type SOA kleines-miststueck.de}
	test=$(nslookup ${target} | grep -e NXDOMAIN -e SERVFAIL)
	if [[ $? -ne 0 || -n "${test}" ]]; then
		[ -n "${IMG_DEBUG}" ] && echo "dns request failed"
		return 1
	fi
}
test_ping() {
	target=${1:-${HOSTNAME}}
	# -c2 count 2 ECHO_REQUEST, -w10 wait 10 seconds for ECHO_RESPONSE
	if ! ping -c2 -w10 ${target} ; then
		[ -n "${IMG_DEBUG}" ] && echo "echo request failed"
		return 1
	fi
}
test_uri() {
	target=${1:-http://${HOSTNAME}}
	# --head show only header
	# --follow follow redirects
	# --user-agent sent custom user agent
	# --fail fast and suppress HTML error message
	if ! curl --fail --connect-timeout 10 --user-agent "docker-healthcheck.sh" --head ${target}
		[ -n "${IMG_DEBUG}" ] && echo "web request failed"
		return 1
	fi
}

###
# test container health
[ -z "${HEALTH_NSLOOKUP}" ] || test_nameserver ${HEALTH_NSLOOKUP} || returnCode=1
[ -z "${HEALTH_PING}" ]     || test_ping ${HEALTH_PING}           || returnCode=1
[ -z "${HEALTH_CURL}" ]     || test_uri ${HEALTH_CURL}            || returnCode=1

###
#	The command's exit status indicates the health status of the container. The possible values are:
#	0: success - the container is healthy and ready for use
#	1: unhealthy - the container isn't working correctly
#	2: reserved - don't use this exit code
exit ${returnCode}
