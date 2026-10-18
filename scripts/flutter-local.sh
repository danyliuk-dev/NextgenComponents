#!/usr/bin/env bash
set -euo pipefail
export FLUTTER_SUPPRESS_ANALYTICS=true
export DASH__SUPPRESS_ANALYTICS=true
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp/nextgen-config}"
exec "${NEXTGEN_FLUTTER:-flutter}" "$@"
