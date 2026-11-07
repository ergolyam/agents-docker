#!/bin/sh
set -e

export MAKI_HOME=/data

exec /usr/local/bin/maki "$@"

