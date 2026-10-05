# All targets that are not files
.PHONY: all configure build open run help

# Only show the output
.SILENT: help

# The default target to run
.DEFAULT_GOAL := help

# Variables
pwdname := $(shell basename `pwd`)

# Try to detect the OS, falling back to 'uname' if $(OS) is empty
ifndef $(OS)
	OS := $(shell uname -s)
endif

configure:
	git config core.hooksPath .githooks
	command -v glab
	command -v gh
	command -v perl

help:             ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m      %s\n", $$1, $$2}'

dist:             ## create a distribution tar file for this program
	git bundle create $(pwdname).bundle HEAD
	git archive --output=$(pwdname).zip HEAD
	git archive --output=$(pwdname).tar.gz HEAD
	git archive --output=$(pwdname).tar.xz HEAD

distclean: $(pwdname).bundle $(pwdname).zip $(pwdname).tar.gz $(pwdname).tar.xz  ## like clean but do not clean installdirs and parent dirs
	$(RM) $^

increment-fedora-version: fedora/Containerfile fedora/Makefile .gitlab-ci.yml  ## Increment the fedora version
	perl -pi -e 's/(fedora)(\d+)/$$1.($$2+1)/ge' $?
increment-debian-version: debian/Containerfile debian/Makefile .gitlab-ci.yml  ## Increment the debian version
	perl -pi -e 's/(debian)(\d+)/$$1.($$2+1)/ge' $?
increment-alpine-version: alpine/Containerfile alpine/Makefile .gitlab-ci.yml  ## Increment the alpine version
	perl -pi -e 's/(alpine)(\d+)/$$1.($$2+1)/ge' $?

check:
	glab ci lint
	gh actions-lint
