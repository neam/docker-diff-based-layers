#!/usr/bin/env bash

mkdir sample-project
cd sample-project
rm *

dd if=/dev/zero of=an-important-file-1 bs=1 count=0 seek=3M
dd if=/dev/zero of=an-important-file-2 bs=1 count=0 seek=1M
dd if=/dev/zero of=an-important-file-3 bs=1 count=0 seek=4M
dd if=/dev/zero of=an-important-file-4 bs=1 count=0 seek=2M
dd if=/dev/zero of=an-important-file-5 bs=1 count=0 seek=6M

echo "some text contents" > sample-1.code
echo "some more text contents" > sample-2.code
echo "even some more text contents" > sample-3.code

echo "FROM debian:jessie" > Dockerfile
echo "RUN apt-get update && apt-get install rsync -yq" >> Dockerfile
echo "COPY . /app" >> Dockerfile
