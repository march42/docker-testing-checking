#!/bin/sh
### alpine image uses busybox

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
#set -e

# at first we assume everyting is peachy
returnCode=0

###
#	signal TRAP
trap "echo -e \"EXITting r=$returnCode\"" EXIT
trap "echo -e \"caught sigHUP\" ; exit" HUP
trap "echo -e \"caught sigINT\" ; exit" INT
trap "echo -e \"caught sigTERM\" ; exit" TERM

###
#	check for interactive TTY
myTTY=$(tty)
if [[ $? -ne 0 || -z "${myTTY}" ]]; then
	echo -e "no TTY"
	returnCode=1
fi

###
#	start iPerf3 server (default port tcp/5201)
if [[ -e /app/start_iperf3 && -x /usr/bin/iperf3 ]]; then
	/usr/bin/iperf3 --server --daemon
	[[ $? -ne 0 ]] && returnCode=1
fi

###
#	start DOCKER_COMMAND
if [[ -z "${DOCKER_COMMAND}" ]]; then
	echo -e "\tjust do nothing for empty DOCKER_COMMAND"
	/bin/true
elif [[ "${DOCKER_COMMAND}" == "SLEEP" ]]; then
	echo -e "\tsleep tight"
	while /bin/sleep 1m; do
		returnCode=$?
	done
else
	${DOCKER_COMMAND}
	[[ $? -ne 0 ]] && returnCode=1
fi

###
exit ${returnCode}
