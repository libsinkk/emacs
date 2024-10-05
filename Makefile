.DEFAULT_GOAL=help

pwdname := $(shell basename `pwd`)
imagename := "ksinkar/fedora-emacs:40"

BUILDER ?= podman

all: Containerfile             ## make all the top-level targets the makefile knows about
	$(BUILDER) build -t $(imagename)  -f Containerfile .
install:          ## install builds packages to
	$(BUILDER) push $(imagename)
uninstall:        ## uninstall the build packages
	HUB_TOKEN=$(curl -s -H "Content-Type: application/json" \
	-X POST -d "{\"username\": \"$HUB_USERNAME\", \"password\": \"$HUB_PASSWORD\"}" \
	https://hub.docker.com/v2/users/login/ | jq -r .token)
	curl -i -X DELETE \
	-H "Accept: application/json" \
	-H "Authorization: JWT $HUB_TOKEN" \
	https://hub.docker.com/v2/repositories/<HUB_USERNAME>/<REPO>/tags/<TAG>
distclean: $(pwdname).bundle $(pwdname).zip $(pwdname).tar.gz $(pwdname).tar.xz  ## like clean but do not clean installdirs and parent dirs
	$(RM) $^
dist:             ## create a distribution tar file for this program
	git bundle create $(pwdname).bundle HEAD
	git archive --output=$(pwdname).zip HEAD
	git archive --output=$(pwdname).tar.gz HEAD
	git archive --output=$(pwdname).tar.xz HEAD
help:             ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m      %s\n", $$1, $$2}'

.PHONY: all dist help install uninstall
