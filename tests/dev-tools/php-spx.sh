#!/usr/bin/env bash
#
# Toggles php-spx the way README.md describes ("Enable/disable php-spx").
# php-spx can profile a plain CLI script too (not just web requests) if you
# set SPX_ENABLED and SPX_REPORT, writing its report under spx.data_dir
# (defaults to /tmp/spx) - that's what we use here to prove it actually
# works. Needs the stack already running (docker compose up --detach).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"
source "${SCRIPT_DIR}/_common.sh"

compose exec -T app magento spx-enable
restart_php_and_web_containers
assert_module_is_loaded SPX

compose exec -T app bash <<'BASH' || fail "php-spx didn't write a profiling report"
mkdir -p /tmp/spx
before=$(find /tmp/spx -type f | wc -l)

SPX_ENABLED=1 SPX_REPORT=full php -r 'usleep(2000);'

after=$(find /tmp/spx -type f | wc -l)
if [ "$after" -le "$before" ]; then
  echo "no new report file showed up in /tmp/spx" >&2
  exit 1
fi
BASH
compose exec -T app rm -rf /tmp/spx

compose exec -T app magento spx-disable
restart_php_and_web_containers
assert_module_is_not_loaded SPX
