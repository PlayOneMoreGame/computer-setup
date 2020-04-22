#!/usr/bin/env bash
#
# Installed to a Windows host by `win-buildkite-setup.ps1` and used
# as the entrypoint for the OMG-Buildkite Service running WSL.
#
# Usage:
#   win-buildkite-entrypoint.sh /path/to/config.env

set -euo pipefail

source <(curl -fsSL https://3xx.onemoregame.com/wsl-buildkite-setup.sh)
