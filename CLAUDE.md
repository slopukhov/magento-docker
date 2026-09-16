# magento-docker

Docker environment for running Magento 2 locally (PHP-FPM + nginx + MariaDB +
OpenSearch + Valkey + RabbitMQ, plus optional dev tooling containers for
MFTF and JMeter).

**Always read README.md before making changes.** It's the source of truth
for how to install, start, configure and use this environment (ports, env
vars, how to enable/disable Xdebug/uopz/xhprof/php-spx, cron, reindex,
tests, etc.). Keep it in sync with docker-compose.yml when you change a
service.

## Layout

- `docker-compose.yml` - all services.
- `build/php/fpm-<version>` - Dockerfiles for each PHP version this project
  has ever supported, kept around as history/reference. `build/php/fpm`
  (no version suffix) is the one actually referenced by docker-compose.yml's
  `app` service - it always matches whatever PHP version is currently
  active, and gets duplicated into a new `fpm-<version>` file whenever the
  active version changes.
- `etc/` - config files bind-mounted into the containers (php.ini, nginx
  conf, per-tool ini files for Xdebug/uopz/xhprof/php-spx/tideways, etc.).
- `etc/php/tools/` - the `magento <command>` scripts (install, config-setup,
  xdebug-enable/disable, uopz-enable/disable, etc.) that get bind-mounted
  into the app container as `/usr/local/bin/magento` and `magento2`.
- `tests/dev-tools/` - standalone scripts that check the Xdebug/uopz/xhprof/
  php-spx toggles actually work end to end (see "Testing" below).
- `.github/workflows/magento-docker-health-check.yml` - CI: builds the
  stack, installs Magento, hits the homepage, and runs everything in
  `tests/dev-tools/`.
- Magento itself lives one level up, at `../repos/magento2ce` (sibling of
  this repo, not inside it) - see README.md for the expected directory
  layout.

## Running it locally

1. `cp .env.dist .env` if `.env` doesn't exist yet.
2. `docker compose up --build --detach` (or `docker-compose`, both work -
   see "docker-compose vs docker compose" below).
3. `docker compose exec app magento install` to install Magento, then
   `magento config-setup`.
4. Add `magento.test` to `/etc/hosts` if it isn't already there.

If port 80/443 is already taken by something else on the host (a common
one on dev machines: another project's reverse proxy container), that's a
host-level conflict, not a bug in this repo - don't "fix" it by changing
this project's ports without asking, since docker-compose.yml intentionally
maps them to the standard HTTP/HTTPS ports for `magento.test`.

### docker-compose vs docker compose

Some environments only have the standalone `docker-compose` binary,
some only have the `docker compose` CLI plugin, some have both. Don't
assume one exists over the other - check first (`command -v docker-compose`)
or use whichever the shared test helpers already picked (see
`tests/dev-tools/_common.sh`'s `compose()` wrapper).

## PHP version status (as of the 8.5 upgrade)

- The project currently targets PHP 8.5 for the `app` service, built from
  `build/php/fpm` (Ubuntu 24.04 base). `build/php/fpm-8.5` is the versioned
  copy of the same Dockerfile, kept for history like the other
  `fpm-<version>` files.
- `slopukhov/php:8.5.10-fpm` is now published on Docker Hub and matches
  `build/php/fpm` exactly (same PHP build, same uopz/xhprof/php-spx setup).
  It's a valid alternative to building locally: switch the `app` service in
  docker-compose.yml back to `image: slopukhov/php:8.5.10-fpm` and drop (or
  comment out) the `build:` block if you want faster startup and don't need
  to change the Dockerfile. Keep building from `build/php/fpm` instead
  whenever you're actually changing something in it (new extension, PHP
  bump, etc.) - the published image won't reflect local edits.
- `php8.5-opcache`, `php8.5-sockets` and `php8.5-ftp` are **not** separate
  apt packages in the `ondrej/php` PPA anymore - they're bundled into
  `php8.5-common`/`php8.5-cli` by default. Don't add them back if you see
  "Unable to locate package" errors; that's the reason.
- `uopz` for PHP 8.5 is built from source (`krakjoe/uopz` @ commit
  `14c8fc2`), not installed via apt - the `php8.5-uopz` PECL/apt package is
  ABI-incompatible with 8.5 (`undefined symbol: zend_exception_get_default`
  at load time). If uopz stops working after a PHP or PPA bump, check
  https://github.com/krakjoe/uopz/issues/186 for a newer commit/release
  that supports the new version.
- `tideways` does not work on any currently-buildable PHP version here -
  there's no `.so` for it anywhere except the old, no-longer-built
  `slopukhov/php:7.3.33-fpm` image. This is a pre-existing gap, not a
  regression from the 8.5 work. If it's ever needed again, it'll need a
  compatible build from source, similar to how uopz and php-spx are built
  in `build/php/fpm`.
- When bumping to a new PHP version, update *both* `build/php/fpm` and
  `build/php/fpm-<new version>` (they're meant to be identical), the
  version-specific volume mounts in docker-compose.yml (`/etc/php/<ver>/...`
  paths and the `php<ver>-fpm.conf` file), and re-run everything in
  `tests/dev-tools/`.

## Testing

Before calling PHP/container-related changes done, actually run things
against the stack rather than just reading the Dockerfile/compose diff:

- `docker compose build app` to make sure the PHP image still builds.
- `docker compose up --detach`, then `docker compose exec app magento
  install` to prove Magento actually comes up.
- Each script in `tests/dev-tools/` (`xdebug.sh`, `uopz.sh`, `xhprof.sh`,
  `php-spx.sh`) enables one of these dev tools the way README.md describes,
  checks it's genuinely doing something (not just present in `php -m`), then
  disables it again. Run them individually:

  ```
  ./tests/dev-tools/xdebug.sh
  ./tests/dev-tools/uopz.sh
  ./tests/dev-tools/xhprof.sh
  ./tests/dev-tools/php-spx.sh
  ```

  They require the stack to already be running and leave it in the same
  on/off state they found it in. These are exactly what
  `.github/workflows/magento-docker-health-check.yml` runs in CI, so if
  you're touching anything these depend on (PHP build, ini files, the
  `magento <tool>-enable/disable` scripts), run them before considering the
  change done.

## Conventions worth keeping in mind here

- Keep comments plain and human-facing - describe what the code does or why
  a non-obvious decision was made, not "the same command a developer would
  run" style narration aimed at an imaginary reader. Don't restate the
  obvious line-by-line.
- `tests/dev-tools/_common.sh` is a generic helper library; it shouldn't
  know about or list the specific scripts that use it. Keep it decoupled.
- New files should end with a trailing newline (GitHub flags files that
  don't).
- Only commit when explicitly asked to.
