###
# image Makefile
# (C) Copyright 2026 by Marc Hefter <marchefter@march42.net>
###
# For general help on Makefiles
# see https://www.gnu.org/software/make/manual/make.html

###
# basic variables
SHELL	?= /bin/bash
DOCKER	?= docker

###
# targets variables
SUBDIRS		= 
flagfiles	= last-run.log docker-build.log docker-push.log
objects		= docker-entrypoint.sh docker-healthcheck.sh docker-command.sh

###
ifneq ($(SUBDIRS),"")
# subdirectory rules
.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
endif

###
# .DEFAULT_GOAL	when running whithout arguments
.DEFAULT_GOAL	:= docker-build.log
# .PHONY		marka goals not producing files
.PHONY: clean

#	create flag file indicating last run
%.log:
	touch $@

#	clean		remove objects and targets
clean:	last-run.log
	-rm $(objects) $(flagfiles)

###
# prepare script rules
docker-entrypoint.sh:
	cat ../script/$@ > $@
#	sed --in-place --regexp-extended \
#		--expression="s#@@PROJECT@@#image-networking#gi" \
#		$@

docker-healthcheck.sh:
	cat ../script/$@ > $@

docker-command.sh:
	cat ../script/$@ > $@

###
IMAGE_REPOSITORY	= alpine
ALPINE_VERSION		= latest
IMAGE_TAG			= networking
DOCKER_BUILD_ARGS	= --build-arg ALPINE_VERSION=$(ALPINE_VERSION)
DOCKER_BUILD_TAGS	= --tag $(IMAGE_REPOSITORY):$(ALPINE_VERSION)-$(IMAGE_TAG)
ifeq ($(ALPINE_VERSION),"latest")
DOCKER_BUILD_TAGS	+= --tag $(IMAGE_REPOSITORY):$(IMAGE_TAG)
endif
# docker rules
#
#	*/docker-build.log
docker-build.log:	$(objects)
	$(DOCKER) build $(DOCKER_BUILD_ARGS) $(DOCKER_BUILD_TAGS) Dockerfile
	touch $@
#
docker-push.log:	docker-build.log
	$(DOCKER) push --all-tags $(IMAGE_REPOSITORY):$(ALPINE_VERSION)-$(IMAGE_TAG)
	touch $@
#
