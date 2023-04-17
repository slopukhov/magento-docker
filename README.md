# magento-docker

`magento-docker` is Docker environment for easy to set up, configure, debug Magento 2.

### Requirements

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Docker](https://docs.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Setup SSH-keys on your github account. (see [docs](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)  for [help](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

* Install Mutagen [docs](https://mutagen.io/documentation/introduction/installation)
* Ensure you do not have `dnsmasq` installed/enabled locally (will be auto-installed if you've use Valet+ to install Magento 2)

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

* RUN `mutagen project start` to start project (Magento 2 install, Magento 2 configuration apply)

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

#### DB query-log

* RUN `docker-compose exec app bash` to connect to docker container
* RUN `cd magento2ce` to go to the root directory of the project
* RUN `bin/magento dev:query-log:enable` to enable DB query-log

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

* Enable: `mutagen project run xdebug-enable`
* Disable: `mutagen project run xdebug-disable`

:warning: Enabled Xdebug may slow your environment. 
 
:exclamation: port `9003` is used for debug. 

#### Emails sending

Sent emails will be saved in folder `~/www/magento2ce/var/tmp/mails/` as .htm files

### Project flushing sessions (to flush the synchronization sessions associated with a project)

* RUN `mutagen project flush`

### Project resetting sessions (to reset the synchronization sessions associated with a project)

* RUN `mutagen project reset`

### Project termination (removes all containers and volumes)

* RUN `mutagen project terminate`

