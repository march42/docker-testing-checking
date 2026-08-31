###
# project Makefile
# (C) Copyright 2026 by Marc Hefter <marchefter@march42.net>
###
# For general help on Makefiles
# see https://www.gnu.org/software/make/manual/make.html

###
# include local toolset settings, if any
-include toolset.mk
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
SUBDIRS			:= 
SUBDIRSCLEAN	:= $(addsuffix .clean,$(SUBDIRS))
flagfiles		:= image-with-appuser.log image-networking.log
objects_appuser		:= image-with-appuser/docker-entrypoint.sh image-with-appuser/docker-healthcheck.sh
objects_networking	:= image-networking/docker-entrypoint.sh image-networking/docker-healthcheck.sh image-networking/docker-command.sh
objects			:= $(objects_appuser) $(objects_networking)

###
# subdirectory rules
.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ -f Makefile
%.clean: %
	$(MAKE) -C $< -f Makefile clean

###
# .DEFAULT_GOAL	when running whithout arguments
.DEFAULT_GOAL	:= all
# .PHONY		marka goals not producing files
.PHONY: clean

#	clean		remove objects and targets
.PHONY:	clean prepare all
clean:	$(SUBDIRSCLEAN)
	-$(RM) $(objects) $(flagfiles)

prepare:	$(objects)

all:	$(objects) $(flagfiles)

###
# image settings
IMAGE_REPOSITORY	?= alpine
ALPINE_VERSION		?= latest
DOCKER_BUILDARGS	+= --build-arg ALPINE_VERSION=$(ALPINE_VERSION)
ifdef IMAGE_DEBUG
ifeq ("$(IMAGE_DEBUG)","false")
$(info disabling IMAGE_DEBUG =$(IMAGE_DEBUG))
DOCKER_BUILDARGS	+= --build-arg IMAGE_DEBUG=
else
$(info setting IMAGE_DEBUG =$(IMAGE_DEBUG))
DOCKER_BUILDARGS	+= --build-arg IMAGE_DEBUG=$(IMAGE_DEBUG)
endif
endif
ifdef IMAGE_PUSH
ifneq ("$(IMAGE_PUSH)","false")
$(info enabling IMAGE_PUSH =$(IMAGE_PUSH))
DOCKER_BUILDARGS	+= --push
endif
endif
ifeq ("$(ALPINE_VERSION)","latest")
$(info using latest ALPINE_VERSION)
IMAGE_APPUSER		:= $(IMAGE_REPOSITORY):appuser
IMAGE_NETWORKING	:= $(IMAGE_REPOSITORY):networking
else
$(info using ALPINE_VERSION ==${ALPINE_VERSION})
IMAGE_APPUSER		:= $(IMAGE_REPOSITORY):$(ALPINE_VERSION)-appuser
IMAGE_NETWORKING	:= $(IMAGE_REPOSITORY):$(ALPINE_VERSION)-networking
endif
BUILDARGS_APPUSER		:= ${DOCKER_BUILDARGS} --tag $(IMAGE_APPUSER)
BUILDARGS_NETWORKING	:= ${DOCKER_BUILDARGS} --tag $(IMAGE_NETWORKING)

# image target short
.PHONY:	appuser appuser-push
appuser: image-with-appuser.log
appuser-push:	image-with-appuser.log
	$(DOCKER) push $(IMAGE_APPUSER)

.PHONY:	networking networking-push
networking: image-networking.log
networking-push:	image-networking.log
	$(DOCKER) push $(IMAGE_NETWORKING)

# image scripts
%.sh:
	$(INSTALL) script/$(@F) $@

# image build
image-with-appuser.log:	image-with-appuser/Dockerfile $(objects_appuser)
	$(DOCKER) build $(BUILDARGS_APPUSER) image-with-appuser
	$(DOCKER) inspect $(IMAGE_APPUSER) > $@ \
	|| $(CAT) /dev/null > $@

image-networking.log:	image-networking/Dockerfile $(objects_networking)
	$(DOCKER) build $(BUILDARGS_NETWORKING) image-networking
	$(DOCKER) inspect $(IMAGE_NETWORKING) > $@ \
	|| $(CAT) /dev/null > $@
