FROM alpine:3.22

ENV VERSION=1.0.0
LABEL maintainer="Marc Hefter <marchefter@march42.net>" \
    description="testing appuser for docker containers" \
    version="${VERSION}"

# APP_UID/APP_GID will set the appuser/appgroup at build time (Dockerfile)
ARG APP_UID=42013
ARG APP_GID=42007
# HOST_UID/HOST_GID will set the appuser/appgroup at run time (entrypoint.sh)
ENV HOST_UID=${APP_UID}
ENV HOST_GID=${APP_GID}

#RUN set -x && \
#    apk --no-cache add --virtual \
#        build-deps \
#        build-base \
#        cmake \
#        linux-headers \
#        openssl-dev \
#        util-linux-dev && \
#    make -j "$(nproc)" && \
#    rm -rf /build
COPY docker-entrypoint.sh /

WORKDIR /app
VOLUME ["/app/data", "/app/log"]

# prepare user account
RUN set -x && \
    /sbin/apk --no-cache add \
        shadow \
        daemontools-encore \
        && \
    /usr/sbin/addgroup --system --gid ${APP_GID} appgroup && \
    /usr/sbin/adduser --system --uid ${APP_UID} --disabled-password --no-create-home --home /var/empty --shell /sbin/nologin --gecos "appuser/appgroup" -G appgroup appuser && \
    /bin/mkdir --mode=0750 --parent /app && \
    /bin/chown --recursive appuser:appgroup /app && \
    /bin/chmod -R g-w,o-rwx /app

#USER appuser:appgroup

# Set up the entry point script and default command
#EXPOSE 42080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh"]
# sleep infinity

