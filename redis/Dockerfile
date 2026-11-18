# base postgresql
FROM redis:alpine

LABEL maintainer="Marc Hefter <marchefter@march42.net>" \
    description="adding appuser to docker containers"

# prepare user account and app directory
RUN set -x && \
    /sbin/apk --no-cache add \
        daemontools-encore \
        shadow \
        tini \
        && \
	echo -e "preparation done."

# load docker-entrypoint.sh to image and ensure file permissions
COPY --chmod=0755 docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh
# Set up the entry point script and default command
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]

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

HEALTHCHECK --interval=5m --timeout=13s --start-period=13m --start-interval=30s CMD /usr/local/bin/redis-cli --raw incr ping

# default volumes
VOLUME ["/data"]
# default command to run
CMD ["/usr/local/bin/redis-server"]
# sleep infinity
