#!/bin/sh
### alpine image uses busybox

# get current uid/gid (id -g appuser give primary group gid, which ist appgroup)
APP_UID=$(/usr/bin/id -u appuser)
APP_GID=$(/usr/bin/id -g appuser)

# prepare appuser/appgroup and permissions
if [ "$(/usr/bin/id -u)" != '0' ]; then
	echo "running as: $(/usr/bin/id)"
elif [[ "${HOST_GID}" != "${APP_GID}" -o "${HOST_UID}" != "${APP_UID}" ]]; then
	# change appuser/appgroup to HOST_UID/HOST_GID
	/usr/sbin/groupmod --gid "${HOST_GID}" appgroup 2>/dev/null || true
	/usr/sbin/usermod --uid "${HOST_UID}" --gid appgroup appuser 2>/dev/null || true
	# change owner of /app
	[ -d "/app" ] && /bin/chown --recursive appuser:appgroup /app 2>/dev/null || true
else
	# nothing to do
fi

# -e    Option errexit    exit immediatly, if a command exits with non-zero status
#set -e

# execute CMD
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# already running as unprivileged user
	exec "$@"
else
	# drop from root to appuser
	/usr/bin/setuidgid appuser "$@"
fi
