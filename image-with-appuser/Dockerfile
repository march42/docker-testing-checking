# base alpine linux version
ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION}

ARG IMG_VERSION="20260820-appuser"
ENV IMG_VERSION=${IMG_VERSION}
ARG IMG_DEBUG
ENV IMG_DEBUG=${IMG_DEBUG}
LABEL maintainer="Marc Hefter <marchefter@march42.net>" \
    description="testing appuser for docker containers" \
    version="${IMG_VERSION}"

# APP_UID/APP_GID will set the appuser/appgroup at build time (Dockerfile)
ARG APP_UID=10000
ARG APP_GID=10000
# HOST_UID/HOST_GID will set the appuser/appgroup at run time (entrypoint.sh)
ENV HOST_UID=${APP_UID}
ENV HOST_GID=${APP_GID}

# prepare user account and app directory
RUN set -x && \
    /sbin/apk --no-cache add \
        shadow \
        daemontools-encore \
        && \
    /usr/sbin/addgroup --system --gid ${APP_GID} appgroup && \
    /usr/sbin/adduser --system --uid ${APP_UID} --disabled-password --no-create-home --home /app --shell /sbin/nologin --gecos "appuser/appgroup" -G appgroup appuser && \
    /usr/bin/install -dD -o appuser -g appgroup -m 0750 /app && \
    /usr/bin/install -o appuser -g appgroup -m 0444 /dev/null /app/IMG_VERSION && \
    { \
        [ -r /etc/os-release ] && source /etc/os-release; \
        echo "IMG_LINUX=${ID}:${VERSION_ID}"; \
        echo "IMG_VERSION=${IMG_VERSION}"; \
        echo "IMG_DEBUG=${IMG_DEBUG}"; \
        echo "IMG_DATE=$(date -uIminutes)"; \
        echo "IMG_BUILD=$(uname -a)"; \
    } > "/app/IMG_VERSION" && \
	echo -e "appuser/appgroup done."

#USER appuser:appgroup
WORKDIR /app
VOLUME ["/app/config", "/app/data", "/app/log"]

# load docker-entrypoint.sh to image and ensure file permissions
COPY --chmod=0755 docker-entrypoint.sh /
# Set up the entry point script and default command
ENTRYPOINT ["/docker-entrypoint.sh"]

#RUN set -x && \
#    apk --no-cache add --virtual \
#        build-deps \
#        build-base \
#        cmake \
#        linux-headers \
#        openssl-dev \
#        util-linux-dev && \
#    make -j "$(nproc)" && \
#    rm -rf /build && \
#    echo -e "build preparation done."

# health check (0=success healthy, 1=unhealthy, 2=reserved - don't use this exit code)
COPY --chmod=0755 docker-healthcheck.sh /
# set up HEALTHCHECK
HEALTHCHECK --interval=5m --timeout=3s --start-period=13m --start-interval=30s CMD /docker-healthcheck.sh

# default command to run
CMD ["/bin/sh"]
# sleep infinity
