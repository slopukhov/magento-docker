#!/usr/bin/env bash

set -ex

source ./.env
export $(cut -s -d= -f1 ./.env)

DOCKER_PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DOCKER_PROJECT_DIR

cp etc/php/tests/acceptance/.env ../repos/magento2ce/dev/tests/acceptance
cp etc/php/tests/acceptance/.credentials ../repos/magento2ce/dev/tests/acceptance

docker-compose exec app magento install

docker-compose exec app magento config-setup

docker-compose exec app magento tests-setup