# base alpine linux version
ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION}

ARG IMG_VERSION="20260831-appuser"
ENV IMG_VERSION=${IMG_VERSION}
ARG IMG_DEBUG
ENV IMG_DEBUG=${IMG_DEBUG}
LABEL maintainer="Marc Hefter <marchefter@march42.net>" \
    description="testing appuser for docker containers" \
    version="${IMG_VERSION}"

# APP_UID/APP_GID will set the appuser/appgroup at build time (Dockerfile)
ARG APP_UID=10000
ARG APP_GID=10000
# APP_USER/APP_GROUP set to the user and group name at build time (Dockerfile)
ENV APP_USER=appuser
ENV APP_GROUP=appgroup

# prepare user account and app directory
RUN set -x && \
    /sbin/apk --no-cache add \
        daemontools-encore \
        shadow \
        tini \
        && \
    /usr/sbin/addgroup --system --gid ${APP_GID} ${APP_GROUP} && \
    /usr/sbin/adduser --system --uid ${APP_UID} --disabled-password --no-create-home --home /app --shell /sbin/nologin --gecos "appuser/appgroup" -G ${APP_GROUP} ${APP_USER} && \
    /usr/bin/install -dD -o ${APP_USER} -g ${APP_GROUP} -m 0750 /app && \
    /usr/bin/install -o ${APP_USER} -g ${APP_GROUP} -m 0444 /dev/null /app/IMG_VERSION && \
    { \
        [ -r /etc/os-release ] && source /etc/os-release; \
        echo "IMG_LINUX=${ID}:${VERSION_ID}"; \
        echo "IMG_VERSION=${IMG_VERSION}"; \
        echo "IMG_DEBUG=${IMG_DEBUG}"; \
        echo "IMG_DATE=$(date -uIminutes)"; \
        echo "IMG_BUILD=$(uname -a)"; \
    } > "/app/IMG_VERSION" && \
	echo -e "appuser/appgroup done."

#USER ${APP_USER}:${APP_GROUP}
WORKDIR /app
#VOLUME ["/app/config", "/app/data", "/app/log"]  # naming VOLUME will always create one

# prepare software packages
#RUN set -x && \
#    /sbin/apk --no-cache add \
#        ca-certificates \
#        certbot \
#    && /usr/sbin/update-ca-certificates \
#    && /usr/bin/certbot \
#    && echo -e "software done."

# TLS certificate files
ENV TLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt
ENV TLS_KEY_FILE=
ENV TLS_CERT_FILE=

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

# load script files to image, ensure file permissions, ensure LF line endings
COPY --chmod=0755 docker-entrypoint.sh docker-healthcheck.sh /
RUN dos2unix /docker-entrypoint.sh /docker-healthcheck.sh
# Set up the entry point script and default command
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
# set up HEALTHCHECK, returning (0=success healthy, 1=unhealthy, 2=reserved - don't use this exit code)
HEALTHCHECK --interval=5m --timeout=13s --start-period=13m --start-interval=30s CMD /docker-healthcheck.sh
# health check environment settings
ENV HEALTH_NSLOOKUP=
ENV HEALTH_PING=$(hostname)
ENV HEALTH_CURL=

# default command to run
CMD ["/bin/sh"]
# sleep infinity
