## running app under appuser account

I use an image of *Alpine Linux* because i like the minimal footprint.

### TLDR

build using appgroup gid=1000 and appuser uid=10000

```sh
docker build --build-arg APP_UID=10000 --build-arg APP_GID=10000 .
```

run using host user uid=2222 and group gid=1111

```sh
docker run --env HOST_UID=2222 --env HOST_GID=1000
```

### build with tags

`docker build --build-arg ALPINE_VERSION=3.24 --tags marchefter/alpine:3.24-appuser --tags marchefter/alpine:appuser .`

### how-to

The image uses `ENTRYPOINT` to modify the appuser and execute `CMD`

see [Dockerfile reference](https://docs.docker.com/reference/dockerfile/#understand-how-cmd-and-entrypoint-interact)
to understand how `CMD` and `ENTRYPOINT` interact.

#### at build stage (Dockerfile)

- create user group `appgroup` (`ARG APP_GID` is gid)
- create user `appuser` (`ARG APP_UID` id uid)
- `chown` WORKDIR /app to `appuser/appgroup`
- `COPY docker-entrypoint.sh` to image
- `ENV HOST_GID` defines GID to use on runtime
- `ENV HOST_UID` defines UID to use on runtime

##### `Dockerfile` build stage `ARG` variables

- `ALPINE_VERSION` to select tag for the `FROM` clause
- `IMG_DEBUG` to apply debugging settings (if set to something not empty)
- `IMG_VERSION` to identify version of the image
- `APP_UID` for the initial uid of appuser
- `APP_GID` for the initial gid of appgroup

#### at run time stage (docker-entrypoint.sh)

- `HOST_GID`/`HOST_UID` can be defined on runtime
- get current APP_GID `id -g appuser`
- get current APP_UID `id -u appuser`
- check `HOST_GID != APP_GID` or `HOST_UID != APP_UID`
  - modify group `appgroup` to gid `HOST_GID`
  - modify user `appuser` to uid `HOST_UID` gid `HOST_GID`
  - `chown` WORKDIR /app to appuser:appgroup
- drop root privileges and exec command `setuidgid appuser "$@"`

##### `Dockerfile` execution stage `ENV` variables

- `IMG_DEBUG` to apply debugging settings (if set to something not empty)
- `IMG_VERSION` to identify version of the image (set by the `ARG IMG_VERSION`)
- `HOST_UID` for the runtime uid of appuser
- `HOST_GID` for the runtime gid of appgroup

#### run image without dropping privileges

Remember: *The privileges are dropped in `docker-entrypoint.sh`*

RUN without ENTRYPOINT script `docker run --entrypoint "" `

#### run image with local user uid/gid

`docker run --env HOST_UID=$(id -u) --env HOST_GID=$(id -g) --rm marchefter/alpine:appuser `

### image user accounts

```/etc/passwd
root:x:0:0:root:/root:/bin/sh
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/mail:/sbin/nologin
news:x:9:13:news:/usr/lib/news:/sbin/nologin
uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin
cron:x:16:16:cron:/var/spool/cron:/sbin/nologin
ftp:x:21:21::/var/lib/ftp:/sbin/nologin
sshd:x:22:22:sshd:/dev/null:/sbin/nologin
games:x:35:35:games:/usr/games:/sbin/nologin
ntp:x:123:123:NTP:/var/empty:/sbin/nologin
guest:x:405:100:guest:/dev/null:/sbin/nologin
nobody:x:65534:65534:nobody:/:/sbin/nologin
appuser:x:10000:10000:appuser/appgroup:/app:/sbin/nologin
```

```/etc/group
root:x:0:root
bin:x:1:root,bin,daemon
daemon:x:2:root,bin,daemon
sys:x:3:root,bin
adm:x:4:root,daemon
tty:x:5:
disk:x:6:root
lp:x:7:lp
kmem:x:9:
wheel:x:10:root
floppy:x:11:root
mail:x:12:mail
news:x:13:news
uucp:x:14:uucp
cron:x:16:cron
audio:x:18:
cdrom:x:19:
dialout:x:20:root
ftp:x:21:
sshd:x:22:
input:x:23:
tape:x:26:root
video:x:27:root
netdev:x:28:
kvm:x:34:kvm
games:x:35:
shadow:x:42:
www-data:x:82:
users:x:100:games
ntp:x:123:
abuild:x:300:
utmp:x:406:
ping:x:999:
nogroup:x:65533:
nobody:x:65534:
appgroup:x:10000:appuser
```

### image os_release

```/etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.24.1
PRETTY_NAME="Alpine Linux v3.24"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"
```

### compared to linuxserver.io PUID/PGID feature

[linuxserver.io](https://linuxserver.io/)
has PUID/PGID support in some of their images.
See [understanding PUID/PGID](https://docs.linuxserver.io/general/understanding-puid-and-pgid/)

