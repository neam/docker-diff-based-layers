#!/usr/bin/env bash

echo "[root]" > /tmp/.rsyncd.conf;
echo "path = /" >> /tmp/.rsyncd.conf;
echo "read only = false" >> /tmp/.rsyncd.conf;
echo "uid = 0" >> /tmp/.rsyncd.conf;
echo "gid = 0" >> /tmp/.rsyncd.conf;

rsync --daemon --port 873 --no-detach -vv --config /tmp/.rsyncd.conf
