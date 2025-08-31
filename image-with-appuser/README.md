## running app under appuser account

### how-to

#### at build stage (Dockerfile)

- create user group `appgroup` (`ARG APP_GID` is gid)
- create user `appuser` (`ARG APP_UID` id uid)
- `chown` WORKDIR /app to `appuser/appgroup`
- `COPY docker-entrypoint.sh` to image
- `ENV HOST_GID` defines GID to use on runtime
- `ENV HOST_UID` defines UID to use on runtime

#### at run time stage (docker-entrypoint.sh)

- `HOST_GID`/`HOST_UID` can be defined on runtime
- get current APP_GID `id -g appuser`
- get current APP_UID `id -u appuser`
- check `HOST_GID != APP_GID` or `HOST_UID != APP_UID`
  - modify group `appgroup` to gid `HOST_GID`
  - modify user `appuser` to uid `HOST_UID` gid `HOST_GID`
  - `chown` WORKDIR /app to appuser:appgroup
- drop root privileges and exec command `setuidgid appuser "$@"`
