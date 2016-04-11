#!/usr/bin/env bash

cd sample-project

echo "FROM sample-project:revision-1" > Dockerfile.based-on-revision-1
echo "COPY . /app" >> Dockerfile.based-on-revision-1
