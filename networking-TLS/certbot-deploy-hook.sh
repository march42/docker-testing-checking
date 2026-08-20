#!/bin/bash
###
# --deploy-hook
#	$RENEWED_LINEAGE will point to the config live subdirectory
#	$RENEWED_DOMAINS will contain a space-delimited list of renewed certificate domains
###
# walk through then RENEWED_DOMAINS list
for VALUE in "${RENEWED_DOMAINS}" ; do
	case ${VALUE} in
		arachne.kleines-miststueck.de)
			# make sure private subdirectory is available - don't modify permissions if it already exists
			[[ -d /srv/docker-compose/private ]] || \
            install --owner=root --group=root --mode=0750 --directory /srv/docker-compose/private
			# make sure files exist - leave permissions untouched if already existing
			[[ -r /srv/docker-compose/private/arachne.key ]] || \
            install --owner=root --group=root --mode=0400 /dev/null /srv/docker-compose/private/arachne.key
			[[ -r /srv/docker-compose/private/arachne.crt ]] || \
            install --owner=root --group=root --mode=0440 /dev/null /srv/docker-compose/private/arachne.crt
			# update files - using cat doesn't change existing permissions
			cat ${RENEWED_LINEAGE}/privkey.pem > /srv/docker-compose/private/arachne.key
			cat ${RENEWED_LINEAGE}/fullchain.pem > /srv/docker-compose/private/arachne.crt
			# check it's running and restart container
			[[ -n "$(docker compose --project-directory /srv/docker-compose ps --quiet arachne)" ]] && \
            docker compose --project-directory /srv/docker-compose restart arachne
			;;
		bia.kleines-miststueck.de)
			# make sure private subdirectory is available - don't modify permissions if it already exists
			[[ -d /srv/docker-compose/private ]] || \
			install --owner=root --group=root --mode=0750 --directory /srv/docker-compose/private
			# make sure files exist - leave permissions untouched if already existing
			[[ -r /srv/docker-compose/private/bia.key ]] || \
			install --owner=root --group=root --mode=0400 /dev/null /srv/docker-compose/private/bia.key
			[[ -r /srv/docker-compose/private/bia.crt ]] || \
			install --owner=root --group=root --mode=0440 /dev/null /srv/docker-compose/private/bia.crt
			# update files - using cat doesn't change existing permissions
			cat ${RENEWED_LINEAGE}/privkey.pem > /srv/docker-compose/private/bia.key
			cat ${RENEWED_LINEAGE}/fullchain.pem > /srv/docker-compose/private/bia.crt
			# check it's running and restart container
			[[ -n "$(docker compose --project-directory /srv/docker-compose ps --quiet bia)" ]] && \
            docker compose --project-directory /srv/docker-compose restart bia
			;;
	esac
done
###
