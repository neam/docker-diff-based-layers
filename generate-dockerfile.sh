#!/usr/bin/env bash

envsubst < "/.docker-image-diff/template.Dockerfile" > "$OUT/Dockerfile"
