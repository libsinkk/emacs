.DEFAULT_GOAL=help

pwdname := $(shell basename `pwd`)
imagename := "fedora-emacs:33"

BUILDER := podman

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
	https://hub.docker.com/v2/repositories/<HUB_USERNAME>/<REPO>/tags/<TAG>/
install-strip:    ## install stripped executables
clean:            ## delete all files that are normally created by running 'make all'.
distclean: $(pwdname).bundle $(pwdname).zip $(pwdname).tar.gz $(pwdname).tar.xz  ## like clean but do not clean installdirs and parent dirs
	$(RM) $^
mostlyclean:      ## like clean but not all the files but not intermediate files
maintainer-clean: ## like distclean but do not delete configure
TAGS:             ## generate TAGS file

dist:             ## create a distribution tar file for this program
	git bundle create $(pwdname).bundle HEAD
	git archive --output=$(pwdname).zip HEAD
	git archive --output=$(pwdname).tar.gz HEAD
	git archive --output=$(pwdname).tar.xz HEAD
check:            ## run self-tests
installcheck:     ## perform installation tests
installdirs:      ## create the install directors
configure:        ## configure the build environment
help:             ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m      %s\n", $$1, $$2}'

.PHONY: configure build run help
