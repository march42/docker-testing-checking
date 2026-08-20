#!/bin/bash
###
# openssl uses $SSL_CERT_FILE
TLS_CA_FILE=${TLS_CA_FILE:-/etc/ssl/certs/ca-certificates.crt}
###
# update private/ca.crt
cat ${TLS_CA_FILE} > /srv/docker-compose/private/ca.crt
# restart whole project, if any service is running
if [[ -n "$(docker compose --project-directory /srv/docker-compose ps --quiet)" ]] ; then
	docker compose --project-directory /srv/docker-compose restart
fi
# restart only running services
VALUE=$(docker compose --project-directory /srv/docker-compose ps --quiet)
[[ -n "${VALUE}" ]] && docker container restart $VALUE
###
