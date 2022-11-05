# magento-docker

`magento-docker` is Docker environment for easy to set up, configure, debug Magento 2.

### Requirements

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Docker](https://docs.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Setup SSH-keys on your github account. (see [docs](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)  for [help](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

* (optional - for Mutagen installation only) Install Mutagen [docs](https://mutagen.io/documentation/introduction/installation)
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

4. Optionally update in `.env` the values for `PROFILE_EDITION` and `PROFILE_SIZE` which will be used when running the performance profile generation command

### Project start

* RUN `mutagen project start` to start project (Magento 2 install, Magento 2 configuration apply)

#### Generate performance profile

* RUN `mutagen project run profile-generate` to generate performance profile

#### Cron run

* RUN `mutagen project run cron` to execute cron command

#### Reindex run

* RUN `mutagen project run reindex` to execute reindex command

#### Cache flush

* RUN `mutagen project run cache-flush` to execute cache flush command

#### Upgrade run

* RUN `mutagen project run upgrade` to execute upgrade command

#### DI compile

* RUN `mutagen project run di-compile` to execute di compile command

#### Tests preparation

* RUN `mutagen project run tests-setup` to execute test preparation command

#### Enable/disable Xdebug 

* Enable: `mutagen project run xdebug-enable`
* Disable: `mutagen project run xdebug-disable`

:warning: Enabled Xdebug may slow your environment. 
 
:exclamation: port `9003` is used for debug. 

#### Emails sending

Sent emails will be saved in folder `~/www/magento2ce/var/tmp/mails/` as .htm files

### Project termination (removes all containers and volumes)

* RUN `mutagen project terminate`

