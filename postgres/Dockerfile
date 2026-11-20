# base postgresql
ARG POSTGRES_VERSION=18-alpine
FROM postgres:${POSTGRES_VERSION}

# for opencontainers annotations see https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.authors="Marc Hefter <marchefter@march42.net>" \
    org.opencontainers.image.title="PostgreSQL" \
    org.opencontainers.image.version="18-alpine v18.7" \
    org.opencontainers.image.url="https://www.postgresql.org/" \
    org.opencontainers.image.documentation="https://www.postgresql.org/docs/" \
    org.opencontainers.image.source="https://github.com/march42/docker-testing-checking" \
    org.opencontainers.image.description="adding appuser to docker container" \
    org.opencontainers.image.licenses="GPL-3.0-or-later OR PostgreSQL"

# APP_USER/APP_GROUP set to the user and group name at build time (Dockerfile)
ENV APP_USER=postgres
ENV APP_GROUP=postgres

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
COPY --chmod=0755 docker-entrypoint.sh docker-healthcheck.sh /
RUN dos2unix /docker-entrypoint.sh /docker-healthcheck.sh
# Set up the entry point script and default command
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
# set up HEALTHCHECK, returning (0=success healthy, 1=unhealthy, 2=reserved - don't use this exit code)
HEALTHCHECK --interval=5m --timeout=13s --start-period=13m --start-interval=30s CMD /docker-healthcheck.sh

# default volumes
VOLUME ["/var/lib/postgresql"]
# default command to run
CMD ["/usr/local/bin/postgres"]
# sleep infinity
