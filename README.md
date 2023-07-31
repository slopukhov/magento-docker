# magento-docker

`magento-docker` is Docker environment for easy to set up, configure, debug Magento 2.

### Requirements

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Docker](https://docs.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Setup SSH-keys on your github account. (see [docs](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)  for [help](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

* Ensure you do not have `dnsmasq` installed/enabled locally (will be auto-installed if you've use Valet+ to install Magento 2)

### Recommendations

* To improve performance enable VirtioFS in your docker app.

VirtioFS is only available to users of the following macOS versions:

macOS 12.2 and above (for Apple Silicon)
macOS 12.3 and above (for Intel)

To enable virtiofs in Docker Desktop:

    Ensure that you are using Docker Desktop version 4.6, available here
    Navigate to ‘Preferences’ (the gear icon) > ‘Experimental Features’
    Select the ‘Use the new Virtualization framework’ and ‘Enable VirtioFS accelerated directory sharing’ toggles
    Click ‘Apply & Restart’

### How to install

#### Steps

1. Create a directory where all repositories will be cloned (used in your IDE)
 
    Proposed structure:
```
    ~/www/magento-docker                    # This repo
    ~/www/repos/magento2ce                  # Magento 2 repo (If you want to install a version other than CE, then simply deploy files of the required version and or extensions to this directory over the files from CE)
```

2. Add `magento.test` to hosts:

```
    sudo -- sh -c "echo '127.0.0.1 magento.test' >> /etc/hosts"
```

3. Copy `.env.dist` in `.env` and update the variables you need. 

4. Optionally, you can update file `etc/php/tools/pre-scripts` to add custom dependencies or run other commands before installation.

5. Optionally, you can update file `etc/php/tools/post-scripts` to run custom commands after installation.

### Project start

* RUN `docker-compose pull` to pull docker images
* RUN `docker-compose up --build --detach` to build docker images

#### Magento 2 install

* RUN `docker-compose exec app magento install` to Magento 2 install

#### Magento 2 config apply

* RUN `docker-compose exec app magento config-setup` to Magento 2 configuration apply

#### Test preparation

* RUN `docker-compose exec app magento tests-setup` to set up test preparation

#### Generate performance profile

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento setup:performance:generate-fixtures -s setup/performance-toolkit/profiles/PROFILE_EDITION/PROFILE_SIZE.xml` to generate performance profile. . Instead of PROFILE_EDITION and PROFILE_SIZE - specify your Magento edition and required profile size
* RUN `bin/magento indexer:reindex` to execute reindex command
* RUN `bin/magento cache:flush` to execute cache flush command

#### Cron run

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento cron:run` to execute cron command

#### Reindex run

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento indexer:reindex` to execute reindex command

#### Change indexers mode

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento indexer:set-mode realtime` to set realtime indexers mode
* RUN `bin/magento indexer:set-mode schedule` to set schedule indexers mode

#### Cache flush

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento cache:flush` to execute cache flush command

#### Upgrade run

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento setup:upgrade` to execute upgrade command
* RUN `bin/magento cache:flush` to execute cache flush command

#### DI compile

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento setup:di:compile` to execute di compile command
* RUN `bin/magento cache:flush` to execute cache flush command

#### Static content deploy

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento setup:static-content:deploy` to execute static-content deploy command

#### Enable production mode

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento deploy:mode:set production` to execute enable production mode command

#### DB query-log

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento dev:query-log:enable` to enable DB query-log

#### Configure the application to use Varnish

* Update the file `etc/varnish/default.vcl` with the necessary configuration described in this documentation https://experienceleague.adobe.com/docs/commerce-operations/configuration-guide/cache/configure-varnish-commerce.html
* Restart varnish: `docker-compose restart varnish`

:exclamation: Access list: `app`, Backend host: `web`, Backend port: `8080`.

#### Tests execution

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project

MFTF
* RUN `vendor/bin/mftf run:test MftfTestName` to run MFTF test. Instead of MftfTestName - specify the real name of the test

PHP Unit
* RUN `vendor/phpunit/phpunit/phpunit --configuration /var/www/magento2ce/dev/tests/unit/phpunit.xml.dist app/code/PhpUnitTestPath` to run PHP Unit test. Instead of PhpUnitTestPath - specify the real PHP Unit test path of the test

Integration
* RUN `rm -rf generated/code && rm -rf generated/metadata` in case of errors in Magento installation before running the Integration test
* RUN `vendor/phpunit/phpunit/phpunit --configuration /var/www/magento2ce/dev/tests/integration/phpunit.xml.dist dev/tests/integration/testsuite/IntegrationTestPath` to run Integration test. Instead of IntegrationTestPath - specify the real integration test path of the test

Api Functional
* RUN `vendor/phpunit/phpunit/phpunit --configuration /var/www/magento2ce/dev/tests/api-functional/phpunit_rest.xml.dist dev/tests/api-functional/testsuite/ApiFunctionalTestPath` to run Api Functional test. Instead of ApiFunctionalTestPath - specify the real Api Functional test path of the test

#### Enable/disable Xdebug 

* Enable: `docker-compose exec app magento xdebug-enable && docker-compose restart app web`
* Disable: `docker-compose exec app magento xdebug-disable && docker-compose restart app web`

:warning: Enabled Xdebug may slow your environment. 
 
:exclamation: port `9003` is used for debug. 

#### Enable/disable uopz (Depends on the availability of the necessary extension in the PHP image used)

* Enable: `docker-compose exec app magento uopz-enable && docker-compose restart app web`
* Disable: `docker-compose exec app magento uopz-disable && docker-compose restart app web`

:exclamation: for example, this extension is present in PHP image: `slopukhov/php:8.1.19-fpm`

#### Enable/disable php-spx (Depends on the availability of the necessary extension in the PHP image used)

* Enable: `docker-compose exec app magento spx-enable && docker-compose restart app web`
* Disable: `docker-compose exec app magento spx-disable && docker-compose restart app web`

Add parameters `?SPX_KEY=dev&SPX_ENABLED=1` to your URL to measure this URL. Example: `https://magento.test/?SPX_KEY=dev&SPX_ENABLED=1`

Open with your browser the following URL: `https://magento.test/?SPX_KEY=dev&SPX_UI_URI=/` to access to the spx web UI control panel with measurement results.

:exclamation: for example, this extension is present in PHP image: `slopukhov/php:8.2.8-fpm`

#### Enable/disable tideways (Depends on the availability of the necessary extension in the PHP image used)

* Enable: `docker-compose exec app magento tideways-enable && docker-compose restart app web`
* Disable: `docker-compose exec app magento tideways-disable && docker-compose restart app web`

:exclamation: for example, this extension is present in PHP image: `slopukhov/php:7.3.33-fpm`

#### Emails sending

Sent emails will be saved in folder `~/www/magento2ce/var/tmp/mails/` as .htm files

### Project termination (removes all containers and volumes)

* RUN `docker-compose down --volumes --remove-orphans`

