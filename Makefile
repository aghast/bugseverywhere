#! /usr/bin/make -f
# :vim: filetype=make : -*- makefile; coding: utf-8; -*-

# Makefile
# Part of Bugs Everywhere, a distributed bug tracking system.
#
# Copyright (C) 2008-2010 Ben Finney <benf@cybersource.com.au>
#                         Chris Ball <cjb@laptop.org>
#                         Gianluca Montecchi <gian@grys.it>
#                         W. Trevor King <wking@drexel.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

SHELL = /bin/bash
RM = rm
#PATH = /usr/bin:/bin  # must include sphinx-build for 'sphinx' target.

#PREFIX = /usr/local
PREFIX = ${HOME}
INSTALL_OPTIONS = "--prefix=${PREFIX}"

# Directories with semantic meaning
DOC_DIR := doc
MAN_DIR := ${DOC_DIR}/man

MANPAGES = be.1
GENERATED_FILES := build libbe/_version.py

MANPAGE_FILES = $(patsubst %,${MAN_DIR}/%,${MANPAGES})
GENERATED_FILES += ${MANPAGE_FILES}


.PHONY: all
all: build


.PHONY: build
build: libbe/_version.py
	python setup.py build

.PHONY: doc
doc: sphinx man

.PHONY: install
install: build doc
	python setup.py install ${INSTALL_OPTIONS}

test: build
	python test.py

.PHONY: clean
clean:
	$(RM) -rf ${GENERATED_FILES}
	$(MAKE) -C ${DOC_DIR} clean


.PHONY: libbe/_version.py
libbe/_version.py:
	bzr version-info --format python > $@

.PHONY: man
man: ${MANPAGE_FILES}

%.1: %.1.sgml
	docbook-to-man $< > $@

.PHONY: sphinx
sphinx:
	$(MAKE) -C ${DOC_DIR} html
