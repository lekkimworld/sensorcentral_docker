#!/bin/sh
JSON=`curl -s -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot?skip_head=false`
NAME=`echo $JSON | jq -r ".data.name"`
TIMESTAMP=`date "+%Y%m%dT%H%M%S"`
FILENAME=/tmp/sensorcentral-prometheus-grafana-backup-$TIMESTAMP.tar.gz
echo "Created snapshot (${NAME}) and creating backup in $FILENAME"
tar cfz $FILENAME /mnt/docker-volumes/prometheus/snapshots/$NAME/* /mnt/docker-volumes/grafana/*
rm -rf /mnt/docker-volumes/prometheus/snapshots/$NAME
