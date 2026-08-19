#!/bin/sh
### alpine image uses busybox

# get current uid/gid (id -g appuser give primary group gid, which ist appgroup)
APP_UID=$(/usr/bin/id -u appuser)
APP_GID=$(/usr/bin/id -g appuser)

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
#set -e

# first we assume everyting is peachy
returnCode=0

# check appuser/appgroup
if [[ "${HOST_GID}" != "${APP_GID}" || "${HOST_UID}" != "${APP_UID}" ]]; then
	returnCode=1
fi
echo "running as: $(/usr/bin/id)"

# check networking
test_nameserver() {
	test=$(nslookup -type=SOA kleines-miststueck.de | grep -e NXDOMAIN -e SERVFAIL)
	if [[ $? -ne 0 || -n "${test}" ]]; then
		return 1
	fi
}
test_ping() {
	target=${1:-kleines-miststueck.de}
	ping -c1 ${target} || /bin/false
}
test_uri() {
	uri=${1:-https://kleines-miststueck.de/}
	curl --head --header --fail ${uri} || /bin/false
}

###
#	The command's exit status indicates the health status of the container. The possible values are:
#	0: success - the container is healthy and ready for use
#	1: unhealthy - the container isn't working correctly
#	2: reserved - don't use this exit code
exit ${returnCode}
