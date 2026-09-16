#!/usr/bin/env bash
#
# Toggles Xdebug the way README.md describes ("Enable/disable Xdebug") and
# checks it's actually doing something once it's on, not just that php -m
# lists it. Needs the stack already running (docker compose up --detach).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"
source "${SCRIPT_DIR}/_common.sh"

compose exec -T app magento xdebug-enable
restart_php_and_web_containers
assert_module_is_loaded xdebug

compose exec -T app php <<'PHP' || fail "xdebug loaded but isn't behaving like Xdebug"
<?php
if (ini_get('xdebug.mode') !== 'debug') {
    fwrite(STDERR, "xdebug.mode is not 'debug'\n");
    exit(1);
}
if (!function_exists('xdebug_info')) {
    fwrite(STDERR, "xdebug_info() is not available\n");
    exit(1);
}
PHP

compose exec -T app magento xdebug-disable
restart_php_and_web_containers
assert_module_is_not_loaded xdebug
