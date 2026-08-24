###
# project Makefile
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
SUBDIRS			= image-with-appuser image-networking
SUBDIRSCLEAN	= $(addsuffix .clean,$(SUBDIRS))
flagfiles		=
objects			=

###
# subdirectory rules
.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
%.clean: %
	$(MAKE) -C $< -f Makefile clean

###
# .DEFAULT_GOAL	when running whithout arguments
.DEFAULT_GOAL	:= subdirs
# .PHONY		marka goals not producing files
.PHONY: clean

#	last-run	create flag file indicating last run
.PHONY:	last-run
last-run:	last-run.log
%.log:
	touch $@

#	clean		remove objects and targets
clean:	last-run.log $(SUBDIRSCLEAN)
	-rm last-run.log $(objects) $(flagfiles)

all:	last-run.log
