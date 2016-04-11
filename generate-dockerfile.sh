#!/usr/bin/env bash

set -x
envsubst < "/.docker-image-diff/template.Dockerfile" > "$OUT/Dockerfile"
