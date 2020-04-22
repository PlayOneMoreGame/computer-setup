#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Run a Windows batch script of the same name as this bash file
exec cmd.exe //q //c "$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}").bat" "$@"
