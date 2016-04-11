#!/usr/bin/env bash

rsync -a -x --human-readable --delete-after --checksum --dry-run --itemize-changes --exclude .docker-image-diff "$RESTRICT_DIFF_TO_PATH/" "rsync://rsync@old/root$RESTRICT_DIFF_TO_PATH/" | tee /.docker-image-diff/changes.rsync.log
