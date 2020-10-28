###############
# BOILERPLATE #
###############
# Import config.
# You can change the default config with `make CONFIG="config_special.env" build`
CONFIG ?= config.env
include $(CONFIG)
export $(shell sed 's/=.*//' $(CONFIG))

.PHONY: help
.DEFAULT_GOAL := help

########
# HELP #
########
help: ## Shows this message.
	@echo -e "Makefile helper for ${NAME} ${VERSION}.\n\nCommands reference:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo
version: ## Output the current version.
	@echo $(VERSION)

###########
# INSTALL #
###########
.ONESHELL:
merge-scripts: ## Merge the scripts in the main script
	@echo Merging scripts into openshift-install-wrapper
	cd scripts && ./.merge-scripts

install: ## Installs the script
	@echo Preparing script
	@sed -i 's/^VERSION=.*/VERSION=$(VERSION)/' openshift-install-wrapper
	@sed -i "s|^__basedir=.*|__basedir=$(TARGETDIR)|" openshift-install-wrapper
	@echo Merging customization scripts
	cd scripts && ./.merge-scripts && cd - &>/dev/null
	@echo Creating target directory $(TARGETDIR)...
	@mkdir -p $(TARGETDIR)/{bin,clusters,config}
	@echo Copying script...
	@cp -f scripts/openshift-install-wrapper $(TARGETDIR)/bin
	@chmod 755 $(TARGETDIR)/bin/openshift-install-wrapper
	@echo "Wrapper installed in $(TARGETDIR)/bin. Please remember to add this location to your PATH to use it."
