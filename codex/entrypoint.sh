#!/bin/sh
set -e

export CODEX_HOME=/data

exec /usr/local/bin/codex --no-daemon "$@"

