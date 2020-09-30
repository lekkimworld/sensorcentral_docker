#!/bin/sh
# https://coderevolve.com/certbot-in-docker/
set -e

# renew certs
/usr/bin/docker run --rm -it --name certbot \
   -v "/mnt/docker-volumes/letsencrypt-docker-nginx/etc/letsencrypt:/etc/letsencrypt" \
   -v "/mnt/docker-volumes/letsencrypt-docker-nginx/var/lib/letsencrypt:/var/lib/letsencrypt" \
   -v "/mnt/docker-volumes/letsencrypt-docker-nginx/data/letsencrypt:/data/letsencrypt" \
   -v "/mnt/docker-volumes/letsencrypt-docker-nginx/var/log/letsencrypt:/var/log/letsencrypt" \
   certbot/certbot renew --webroot -w /data/letsencrypt --quiet

# restart nginx
/usr/bin/docker restart services_nginx_1
