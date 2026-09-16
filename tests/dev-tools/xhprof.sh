#!/usr/bin/env bash
#
# Toggles xhprof the way README.md describes ("Enable/disable xhprof") and
# checks it actually produces profiling data, since a module that's loaded
# but silently returns nothing wouldn't be much use. Needs the stack already
# running (docker compose up --detach).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"
source "${SCRIPT_DIR}/_common.sh"

compose exec -T app magento xhprof-enable
restart_php_and_web_containers
assert_module_is_loaded xhprof

compose exec -T app php <<'PHP' || fail "xhprof didn't return any profiling data"
<?php
function some_function_to_profile()
{
    usleep(2000);
}

xhprof_enable();
some_function_to_profile();
$profile = xhprof_disable();

// xhprof always records an entry for the top-level script under "main()",
// so an empty or missing result means profiling never really ran.
if (!is_array($profile) || !isset($profile['main()']) || count($profile) === 0) {
    fwrite(STDERR, "xhprof_disable() returned no profiling data\n");
    exit(1);
}
PHP

compose exec -T app magento xhprof-disable
restart_php_and_web_containers
assert_module_is_not_loaded xhprof
