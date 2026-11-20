ARG REDIS_VERSION=8-alpine
FROM redis:${REDIS_VERSION}

# for opencontainers annotations see https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.authors="Marc Hefter <marchefter@march42.net>" \
    org.opencontainers.image.title="Redis" \
    org.opencontainers.image.version="alpine v8" \
    org.opencontainers.image.url="https://redis.io/" \
    org.opencontainers.image.documentation="https://redis.io/docs/" \
    org.opencontainers.image.source="https://github.com/march42/docker-testing-checking" \
    org.opencontainers.image.description="adding appuser to docker container" \
    org.opencontainers.image.licenses="RSALv2 OR SSPLv1 OR AGPLv3"

# APP_USER/APP_GROUP set to the user and group name at build time (Dockerfile)
ENV APP_USER=redis
ENV APP_GROUP=redis

# prepare user account and app directory
RUN set -x && \
    /sbin/apk --no-cache add \
        daemontools-encore \
        shadow \
        tini \
        && \
	echo -e "preparation done."

# TLS certificate files
ENV TLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt
ENV TLS_KEY_FILE=
ENV TLS_CERT_FILE=

# load script files to image, ensure file permissions, ensure LF line endings
COPY --chmod=0755 docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh
# Set up the entry point script and default command
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
# set up HEALTHCHECK, returning (0=success healthy, 1=unhealthy, 2=reserved - don't use this exit code)
HEALTHCHECK --interval=5m --timeout=13s --start-period=13m --start-interval=30s CMD /usr/local/bin/redis-cli --raw incr ping

# default volumes
VOLUME ["/data"]
# default command to run
CMD ["/usr/local/bin/redis-server"]
# sleep infinity
