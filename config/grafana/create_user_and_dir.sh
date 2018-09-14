#!/bin/bash
groupadd grafana
useradd -r -u 472 -g grafana grafana
mkdir -p /mnt/docker-volumes/grafana
chown -R grafana /mnt/docker-volumes/grafana/
