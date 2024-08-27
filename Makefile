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
merge-scripts: create-main-wrapper ## Merge the scripts in the main script
	@echo Merging scripts into openshift-install-wrapper.
	cd src/scripts && ./.merge-scripts.sh
	
merge-templates: ## Merge the install-config templates in the templates file
	@echo Merging install-config templates into variables file.
	cd src/config/templates && ./.merge-templates.sh

create-main-wrapper: ## Creates the wrapper with all the src/ content
	@echo Combining source files into openshift-install-wrapper.
	@cat src/control/00_init.sh src/config/*.sh src/helpers/*.sh src/actions/*.sh src/control/99_execute.sh > openshift-install-wrapper
	@chmod +x openshift-install-wrapper

create-binary-wrappers: ## Install helper wrappers for oc, kubectl, openshift-install
	@echo Preparing binary wrappers.
	@sed -i 's/^VERSION=.*/VERSION=$(VERSION)/' openshift-install-wrapper
	@sed -i "s|^__basedir=.*|__basedir=$(TARGETDIR)|" openshift-install-wrapper
	@sed -i "s|^WRAPPER_BASEDIR=.*|WRAPPER_BASEDIR=$(TARGETDIR)/bin|" bin/openshift-install
	@sed -i "s|^WRAPPER_BASEDIR=.*|WRAPPER_BASEDIR=$(TARGETDIR)/bin|" bin/oc
	@sed -i "s|^WRAPPER_BASEDIR=.*|WRAPPER_BASEDIR=$(TARGETDIR)/bin|" bin/kubectl

create-dirs: ## Create directories
	@echo Creating target directory $(TARGETDIR).
	@mkdir -p $(TARGETDIR)/{bin,clusters,config}

copy-binary-wrappers: ## Copy wrappers to binaries directory
	@echo Copying wrappers.
	@mv -f openshift-install-wrapper $(TARGETDIR)/bin
	@cp -f bin/* $(TARGETDIR)/bin
	@chmod 755 $(TARGETDIR)/bin/openshift-install-wrapper
	@echo "Wrappers installed in $(TARGETDIR)/bin. Please remember to add this location to your PATH to use it."

install: create-dirs merge-templates create-main-wrapper create-binary-wrappers merge-scripts copy-binary-wrappers ## Installs the script
