#!/usr/bin/env bash

# Description:    Script to run IPI installations from OpenShift 4 where supported
# Author:         Sergio Garcia (soukron@gmbros.net)
# Source/License: https://github.com/soukron/openshift-install-wrapper

# exit immediately on error
set -e

# detect whether output is piped or not.
[[ -t 1 ]] && PIPED=0 || PIPED=1

