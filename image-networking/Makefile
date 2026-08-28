###
# image Makefile
# (C) Copyright 2026 by Marc Hefter <marchefter@march42.net>
###
# For general help on Makefiles
# see https://www.gnu.org/software/make/manual/make.html

###
# include local toolset settings, if any
-include ../toolset.mk
# set simple commands as fall-back option
SHELL	?= /bin/sh
INSTALL	?= install
TOUCH	?= touch
RM		?= rm
CAT		?= cat
SED		?= sed
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
	$(TOUCH) $@

#	clean		remove objects and targets
clean:	last-run.log
	-$(RM) $(objects) $(flagfiles)

###
# prepare script rules
docker-entrypoint.sh:
	$(INSTALL) ../script/$@ $@
#	$(SED) --in-place --regexp-extended \
#		--expression="s#@@PROJECT@@#image-networking#gi" \
#		$@

docker-healthcheck.sh:
	$(INSTALL) ../script/$@ $@

docker-command.sh:
	$(INSTALL) ../script/$@ $@

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
	$(TOUCH) $@
#
docker-push.log:	docker-build.log
	$(DOCKER) push --all-tags $(IMAGE_REPOSITORY):$(ALPINE_VERSION)-$(IMAGE_TAG)
	$(TOUCH) $@
#
