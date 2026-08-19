#!/bin/sh
### alpine image uses busybox

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
set -e

# get current uid/gid (id -g appuser give primary group gid, which ist appgroup)
APP_UID=$(/usr/bin/id -u appuser)
APP_GID=$(/usr/bin/id -g appuser)

# prepare appuser/appgroup and permissions
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# we are already unprivileged user
	[ -n "${IMG_DEBUG}" ] && echo -e "running as: $(/usr/bin/id)"
else
	# change user and/or group to HOST_UID/HOST_GID
	if [[ "${HOST_GID}" != "${APP_GID}" ]]; then
		[ -n "${IMG_DEBUG}" ] && echo -e "change GID:\t${HOST_GID}"
		/usr/sbin/groupmod --non-unique --gid "${HOST_GID}" appgroup || true
	fi
	if [[ "${HOST_UID}" != "${APP_UID}" ]]; then
		[ -n "${IMG_DEBUG}" ] && echo -e "change UID:\t${HOST_UID}"
		# split to multiple usermod calls, ensure consistency
		# modify uid
		/usr/sbin/usermod --non-unique --uid "${HOST_UID}" appuser || true
		# modify primary group
		/usr/sbin/usermod --gid "${HOST_GID}" appuser || true
		# modify additional group membership (this should be unneccessary, groupmod was called with --non-unique)
		[[ "${HOST_GID}" != "$(/bin/grep -e "^appgroup:" /etc/group | /usr/bin/cut -d ":" -f3)" ]] && /usr/sbin/usermod --groups appgroup appuser || true
	fi
	# modify appuser home directory (not for HOME=/app otherwise all permissions on mounted host files would be messed up)
	APPUSER_HOME=$(/bin/grep -e "^appuser:" /etc/passwd | /usr/bin/cut -d ":" -f6)
	#/bin/chown --recursive appuser:appgroup ${APPUSER_HOME} 2>/dev/null || true
	# modify filesystem ownership, otherwise /app will be inaccessible (mode=0750)
	# find -xdev only changes ownership on the local image
	/usr/bin/find /app -xdev -exec /bin/chown appuser:appgroup {} \;
fi

# execute CMD
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# already running as unprivileged user
	exec "$@"
else
	# make sure, we have setuidgid available
	[ -x /usr/bin/setuidgid ] || apk --no-cache add daemontools-encore
	# drop from root to appuser
	[ -n "${IMG_DEBUG}" ] && echo -e "command:\t$@"
	/usr/bin/setuidgid appuser "$@"
	[ -n "${IMG_DEBUG}" ] && echo -e "exit:\t$?"
fi
