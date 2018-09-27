# Prometheus setup on VM #

- [Prometheus setup on VM](#prometheus-setup-on-vm)
    - [Overview](#overview)
    - [1) Container setup and start scripts (/scripts)](#1-container-setup-and-start-scripts-scripts)
    - [2) Systemd services (/systemd)](#2-systemd-services-systemd)
    - [3) Application configuration (/config)](#3-application-configuration-config)
    - [Tips and notes](#tips-and-notes)

## Overview ##

This is a note for setting up docker container for a prometheus setup on an Ubuntu VM. E.g. hosted by Digital Ocean

* Following images/containers could be considered:
    * __`quay.io/prometheus/prometheus`__
        *  Scraber, data store, alerting rules
    * __`grafana/grafana`__
        *  For graph drawing on prometheus (and other) data sources
    * __`quay.io/prometheus/alertmanager (optional)`__
        *  For understanding and taking action on alerts emitted from prometheus
    *  __`prom/pushgateway (optional)`__
        *  For pushing metrics instead of scrabing. Note that prometheus must still scrabe the push gateway - it's therefore more like a proxy than a push-cabability. Prometheus is build on a pull architecture.

After setup, you're able to:
* Access Prometheus components on their default ports (e.g. Grafana on http://localhost:3000 and Prometheus on http://localhost:9090)
* Manipulate config files in VMs /mnt/... folder
* Start/stop containers through systemd: `systemctl start docker-nerdbox-prometheus`

In order for this to work, you need to go through the following sections:

## 1) Container setup and start scripts (/scripts) ##
Could be placed anywhere. Systemd service files in /systemd assume they're in the PATH

Scripts will setup a container (incl config), start it, and continue running until the container exists. Note that:
* All scripts uses host machine's /mnt/... for persistent data storage
* All scripts assumes a docker network is setup (e.g. `docker network create nerdbox-prometheus`)
* Scripts are designed to not exit as long as the container runs. This makes them suitable for running through a service runner like systemd

## 2) Systemd services (/systemd) ##
Files for controlling /scripts files through `systemctl`
Could be placed in /etc/systemd/system

## 3) Application configuration (/config) ##
The application in each container is configured as documented on the respective application websites. Generally config files are placed in /mnt/... named depending on the application and are editable directly in /mnt/... (beware of permission settings).

/config contains sample configuration files for selected applications:

* Grafana
    * See docs. Sample config with [auth.google] section populated
* Prometheus
    * See docs. /config/prometheus for inspiration
    * Securing Prometheus is best done fronting with nginx using basic auth (see the nginx config file). Benefit of this is also that Grafana has anonymous access while external access may be authenticated. Password file should be generated using the `htpasswd` commmand using `htpasswd -c <filename> <username>` i.e. something like `htpasswd -c .htpasswd jdoe` and the resulting .htpasswd file stuck in the nginx configuration directory
* Prometheus Alert Manager
    * See docs for alertmanager.yml and templates/
* Prometheys Push Gateway
    * N/A

## Tips and notes ##
* Run scripts directly to see if containers can be setup and start correctly. Note that if the script fails, you might end up in a state from where the script cannot run before you've removed the container created by the script (`docker container rm nerdbox-prometheus`)
* When containers fail to start, hints are often in the containers output/log (`docker container logs nerdbox-prometheus -t`)
* Consider a docker CLI-based UI like [DRY](https://moncho.github.io/dry/) or a webbased to maintain overview of container setup
* `docker pull quay.io/prometheus/prometheus` to pull latest stable version of component. Beware this might change configuration file structure and therefore break your configs

- Grafana runs the docker container using a user with uid 472 to create suitable user and allow to access grafana dir - see config/grafana/create_user_and_dir.sh

- Crontab used to auto-renew let's encrypt cert (see https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx)
```
0 23 * * * docker run --rm -it --name certbot -v "/mnt/docker-volumes/letsencrypt-docker-nginx/etc/letsencrypt:/etc/letsencrypt" -v "/mnt/docker-volumes/letsencrypt-docker-nginx/var/lib/letsencrypt:/var/lib/letsencrypt" -v "/mnt/docker-volumes/letsencrypt-docker-nginx/data/letsencrypt:/data/letsencrypt" -v "/mnt/docker-volumes/letsencrypt-docker-nginx/var/log/letsencrypt:/var/log/letsencrypt" certbot/certbot renew --webroot -w /data/letsencrypt --quiet && docker kill --signal=HUP production-nginx-container
```

