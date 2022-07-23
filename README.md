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

4. Optionally update in `.env` the values for `PROFILE_EDITION` and `PROFILE_SIZE` which will be used when running the performance profile generation command

### Project start

* RUN `docker-compose pull` to pull docker images
* RUN `docker-compose up --build --detach` to build docker images

#### Magento 2 install

* RUN `docker-compose exec app magento install` to Magento 2 install

#### Magento 2 config apply

* RUN `docker-compose exec app magento config-setup` to Magento 2 configuration apply

#### Generate performance profile

* RUN `docker-compose exec app magento profile-generate` to generate performance profile

#### Cron run

* RUN `docker-compose exec app magento cron` to execute cron command

#### Reindex run

* RUN `docker-compose exec app magento reindex` to execute reindex command

#### Cache flush

* RUN `docker-compose exec app magento cache-flush` to execute cache flush command

#### Upgrade run

* RUN `docker-compose exec app magento upgrade` to execute upgrade command

#### DI compile

* RUN `docker-compose exec app magento di-compile` to execute di compile command

#### Tests preparation

* RUN `docker-compose exec app magento tests-setup` to execute test preparation command

#### Enable/disable Xdebug 

* Enable: `docker-compose exec app magento xdebug-enable && docker-compose restart app web`
* Disable: `docker-compose exec app magento xdebug-disable && docker-compose restart app web`

:warning: Enabled Xdebug may slow your environment. 
 
:exclamation: port `9003` is used for debug. 

#### Emails sending

Sent emails will be saved in folder `~/www/magento2ce/var/tmp/mails/` as .htm files

### Project termination (removes all containers and volumes)

* RUN `docker-compose down --volumes --remove-orphans`

