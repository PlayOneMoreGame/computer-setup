ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CORES ?= $(shell sysctl -n hw.ncpu || echo 4)
INTUNE_DIR:=$(ROOT_DIR)/intune
INTUNE_WINAPP_UTIL_PATH:=$(ROOT_DIR)/bin/IntuneWinAppUtil.exe


.DEFAULT_GOAL := list
.ONESHELL:

INTUNE_MODULES := lib bootstrap developer programmer
define INTUNE

intune-pkg-$1:
	$(INTUNE_WINAPP_UTIL_PATH) -c $(INTUNE_DIR)/$1 -s install.bat -o $(INTUNE_DIR)
	mv $(INTUNE_DIR)/install.intunewin $(INTUNE_DIR)/PS_$1.intunewin

endef
$(foreach component,$(INTUNE_MODULES),$(eval $(call INTUNE,$(component))))


###############################################################################
#                                 Utilities                                   #
###############################################################################

# https://stackoverflow.com/a/26339924/11547115
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
