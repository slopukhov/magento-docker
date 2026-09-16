#!/usr/bin/env bash
#
# Shared helper functions for checking that a PHP extension in the "app"
# container can be turned on and off, and that it actually works once
# enabled.
#
# Assumes the magento-docker stack is already running
# (docker compose up --detach).

set -uo pipefail

# Some machines only have the classic "docker-compose" binary, others only
# have the newer "docker compose" plugin. This wrapper tries the classic
# name first and falls back to the plugin, so every script here works the
# same way locally and in CI without needing any changes.
compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

# Prints an error and stops the script.
fail() {
  echo "FAILED: $1" >&2
  exit 1
}

# Changing a PHP config file (like xdebug.ini) only takes effect once
# php-fpm restarts.
restart_php_and_web_containers() {
  echo "Restarting the app and web containers so PHP picks up the config change..."
  compose restart app web
  # Give php-fpm a few seconds to finish starting back up.
  sleep 3
}

# Confirms a PHP extension is currently loaded by asking PHP itself, via
# `php -m` (PHP's own "list loaded modules" command), instead of just
# reading the ini file - editing a config file is not proof that PHP was
# able to actually load the extension.
assert_module_is_loaded() {
  local module_name="$1"
  if ! compose exec -T app php -m | grep -qi "^${module_name}$"; then
    fail "'${module_name}' should be loaded, but 'php -m' does not list it"
  fi
  echo "Confirmed: PHP has '${module_name}' loaded."
}

# Same idea, but for after a *-disable command - the module should be gone.
assert_module_is_not_loaded() {
  local module_name="$1"
  if compose exec -T app php -m | grep -qi "^${module_name}$"; then
    fail "'${module_name}' should not be loaded, but 'php -m' still lists it"
  fi
  echo "Confirmed: PHP no longer has '${module_name}' loaded."
}
