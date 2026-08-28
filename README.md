# docker-testing-checking

Here i check and test some handling of docker.

## image with appuser and uid/gid change support

**Running an image app with specific UID/GID**
needs a mechanism to prepare a specific user/group
and drop privileges to this user.

[image-with-appuser](./image-with-appuser/)
does this by creating appuser at build time
and modify uid/gid with ENTRYPOINT script.

## image with support for USER setting

**Running an image with `--user=nonexistent` fails**
because user doesn't exist on image.

## scripts

### docker-entrypoint.sh

Used to prepare and handle PUID/PGID.

* only if running as root (uid=0)
  1. change user group appgroup gid to PGID
  2. change user account appuser uid to PUID, primary group gid to PGID
  3. add supplemental group appgroup, if not appuser's primary group
  4. chown appuser's home directory
  5. chown /app directory
* run COMMAND through `exec` or `setuidgid appuser`

catch signals; HUP, INT, TERM

### docker-healthcheck.sh

Script checking and reporting container health.

The scripts's exit status indicates the container is healthy or not.

| retval | meaning | note |
|-------:|---------|------|
| 0 | healthy, container is healthy and ready to use | |
| 1 | unhealthy, container is not healthy | could be crashed, starting up, shutting down |
| 2 | reserved | don't use this exit code |

The script has some default checks you can use, without modifying the script,
by setting following environment variables.

| variable        | usage   | note |
|:----------------|---------|------|
| HEALTH_NSLOOKUP | call `nslookup`, the check against `NXDOMAIN` and `SERVFAIL` | e.g. ='-type SOA kleines-miststueck.de' will check for domains SOA record |
| HEALTH_PING     | call `ping -c2 -w10` | additional options and hostname; e.g. `-4 ipv4.kleines-miststueck.de` or `-6 ipv6.kleines-miststueck.de` |
| HEALTH_CURL     | call `curl --head` | additional options and URI e.g. `--ipv6 https://ipv6.kleines-miststueck.de/` |

### docker-command.sh
