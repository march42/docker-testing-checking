#!/bin/sh
### alpine image uses busybox

###
#	signal TRAP
trap "echo -e \"EXITting\"" EXIT
trap "echo -e \"caught sigHUP\" ; exit" HUP
trap "echo -e \"caught sigINT\" ; exit" INT
trap "echo -e \"caught sigTERM\" ; exit" TERM

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
set -e

# get current uid/gid (id -g appuser give primary group gid, which ist appgroup)
APP_USER=appuser
APP_UID=$(/usr/bin/id -u ${APP_USER})
APP_GROUP=appgroup
APP_GID=$(/usr/bin/id -g ${APP_GROUP})

# prepare appuser/appgroup and permissions
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# we are already unprivileged user
	[ -n "${IMG_DEBUG}" ] && echo -e "running as: $(/usr/bin/id)"
elif [[ -n "${HOST_UID:=${PUID}}" ]] || [[ -n "${HOST_GID:=${PGID}}" ]]; then
	# we need usermod and groupmod installed
	if [[ ! -x /usr/sbin/groupmod ]] || [[ ! -x /usr/sbin/usermod ]]; then
		/sbin/apk --no-cache add shadow || true		# install necessary package
	fi
	# change user and/or group to HOST_UID/HOST_GID
	if [[ -n "${HOST_GID}" ]] && [[ "${HOST_GID}" != "${APP_GID}" ]]; then
		[ -n "${IMG_DEBUG}" ] && echo -e "change GID:\t${HOST_GID}"
		/usr/sbin/groupmod --non-unique --gid "${HOST_GID}" ${APP_GROUP} || true
	fi
	if [[ -n "${HOST_UID}" ]] && [[ "${HOST_UID}" != "${APP_UID}" ]]; then
		[ -n "${IMG_DEBUG}" ] && echo -e "change UID:\t${HOST_UID}"
		# split to multiple usermod calls, ensure consistency
		# modify uid
		/usr/sbin/usermod --non-unique --uid "${HOST_UID}" ${APP_USER} || true
		# modify primary group
		/usr/sbin/usermod --gid "${HOST_GID}" ${APP_USER} || true
		# modify additional group membership (this should be unneccessary, groupmod was called with --non-unique)
		[[ "${HOST_GID}" != "$(/bin/grep -e "^${APP_GROUP}:" /etc/group | /usr/bin/cut -d ":" -f3)" ]] \
			&& /usr/sbin/usermod --groups ${APP_GROUP} ${APP_USER} || true
	fi
	# modify appuser home directory
	APPUSER_HOME=$(/bin/grep -e "^${APP_USER}:" /etc/passwd | /usr/bin/cut -d ":" -f6)
	/usr/bin/find ${APPUSER_HOME} -xdev -exec /bin/chown ${APP_USER}:${APP_GROUP} {} \;
	# modify filesystem ownership, otherwise /app will be inaccessible (mode=0750)
	# do not just chown/chmod /app otherwise all permissions on mounted host files would be messed up
	# find -xdev only changes ownership on the local image
	[[ ! -d /app ]] || /usr/bin/find /app -xdev -exec /bin/chown ${APP_USER}:${APP_GROUP} {} \;
fi

# execute CMD
if [ -x /usr/local/bin/docker-entrypoint.sh ]; then
	# calling /usr/local/bin/docker-entrypoint.sh
	/usr/local/bin/docker-entrypoint.sh ${@}
elif [ "$(/usr/bin/id -u)" != '0' ]; then
	# already running as unprivileged user
	exec "$@"
else
	# make sure, we have setuidgid available
	[ -x /usr/bin/setuidgid ] || apk --no-cache add daemontools-encore || true
	# drop from root to appuser
	[ -n "${IMG_DEBUG}" ] && echo -e "command:\t$@"
	/usr/bin/setuidgid ${APP_USER} "$@"
	[ -n "${IMG_DEBUG}" ] && echo -e "exit:\t$?"
fi
