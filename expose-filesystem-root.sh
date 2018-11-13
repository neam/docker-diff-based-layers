#!/usr/bin/env bash

echo "[root]" > /tmp/.rsyncd.conf;
echo "path = /" >> /tmp/.rsyncd.conf;
echo "read only = false" >> /tmp/.rsyncd.conf;
rsync --daemon --port 873 --no-detach -vv --config /tmp/.rsyncd.conf
