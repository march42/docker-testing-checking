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
