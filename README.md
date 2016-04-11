Example usage:

```
export RESTRICT_DIFF_TO_PATH=/app
export OLD_IMAGE=very-simple-app-revision-1
export NEW_IMAGE=very-simple-app-revision-2
docker-compose -f rsync-image-diff.docker-compose.yml up
docker-compose -f process-image-diff.docker-compose.yml up
cd output
docker build -t very-simple-app-revision-2-processed .
cd ..
```

Verify that the processed new image has a small size layer with the changes:

```
docker history very-simple-app-revision-2-processed
```

Verify that the processed new image contains the same contents as the original:

```
export RESTRICT_DIFF_TO_PATH=/app
export OLD_IMAGE=very-simple-app-revision-2
export NEW_IMAGE=very-simple-app-revision-2-processed
docker-compose -f rsync-image-diff.docker-compose.yml up
```
