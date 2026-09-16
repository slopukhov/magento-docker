#!/usr/bin/env bash
#
# Toggles uopz the way README.md describes ("Enable/disable uopz"). uopz's
# whole job is overriding function behaviour at runtime (that's how Magento's
# own tests mock things), so the real check here is doing exactly that.
# Needs the stack already running (docker compose up --detach).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"
source "${SCRIPT_DIR}/_common.sh"

compose exec -T app magento uopz-enable
restart_php_and_web_containers
assert_module_is_loaded uopz

compose exec -T app php <<'PHP' || fail "uopz couldn't override a function's return value"
<?php
function example_function_to_override()
{
    return 'the real value';
}

uopz_set_return('example_function_to_override', 'overridden value', false);

$result = example_function_to_override();
if ($result !== 'overridden value') {
    fwrite(STDERR, "uopz_set_return() had no effect, got: {$result}\n");
    exit(1);
}
PHP

compose exec -T app magento uopz-disable
restart_php_and_web_containers
assert_module_is_not_loaded uopz
