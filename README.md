Docker Diff-Based Layers
========================

A way to work around the fact that subsequent `COPY . /app` commands re-adds all files in every layer instead of only the files that have changed.

Use these tools to build an image that includes a layer with only the changed files in comparison with an already pushed image/tag.

## Caveats

Your images needs to have rsync installed.

## Example

### Create and build the image for a sample project

```
docker-compose -f shell.docker-compose.yml run --rm shell ./generate-sample-project.sh 
cd sample-project; docker build -t sample-project:revision-1 .; cd ..
```

Inspect the layer sizes:
```
docker history sample-project:revision-1
```

Output:
```
IMAGE               CREATED              CREATED BY                                      SIZE                COMMENT
d4b30af167f4        3 seconds ago        /bin/sh -c #(nop) COPY dir:68b8f374d8731b8ad8   16.78 MB
c898fe1daa44        About a minute ago   /bin/sh -c apt-get update && apt-get install    10.77 MB
39a8a358844a        4 months ago         /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B
b1dacad9c5c9        4 months ago         /bin/sh -c #(nop) ADD file:5afd8eec1dc1e7666d   125.1 MB
```

### Make some changes to the sample project

```
docker-compose -f shell.docker-compose.yml run --rm shell ./modify-sample-project.sh 
```

### Verify that basing the project images on the revision 1 image tag contents does not lead to desired outcome

Verify that subsequent `COPY . /app` commands re-adds all files in every layer instead of only the files that have changed.
```
docker-compose -f shell.docker-compose.yml run --rm shell ./base-sample-project-images-on-revision-1.sh 
cd sample-project; docker build -f Dockerfile.based-on-revision-1 -t sample-project:revision-2-based-on-revision-1 .; cd ..
docker history sample-project:revision-2-based-on-revision-1
```

Output:
```
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
4a3115eaf267        3 seconds ago       /bin/sh -c #(nop) COPY dir:61d102421e6692b677   16.78 MB
d4b30af167f4        25 seconds ago      /bin/sh -c #(nop) COPY dir:68b8f374d8731b8ad8   16.78 MB
c898fe1daa44        2 minutes ago       /bin/sh -c apt-get update && apt-get install    10.77 MB
39a8a358844a        4 months ago        /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B
b1dacad9c5c9        4 months ago        /bin/sh -c #(nop) ADD file:5afd8eec1dc1e7666d   125.1 MB
```

Even though we added/changed only a few bytes, all files are re-added and 16.78 MB is added to the total image size.

Also, the file(s) that we removed did not get removed.

### Create an image with an optimized layer

```
cd sample-project; docker build -t sample-project:revision-2 .; cd ..
export RESTRICT_DIFF_TO_PATH=/app
export OLD_IMAGE=sample-project:revision-1
export NEW_IMAGE=sample-project:revision-2
docker-compose -f rsync-image-diff.docker-compose.yml up
docker-compose -f shell.docker-compose.yml -f process-image-diff.docker-compose.yml up
cd output; docker build -t sample-project:revision-2-processed .; cd ..
```

Verify that the processed new image has smaller sized layers with the changes:
```
docker history sample-project:revision-2-processed
```

Output:
```
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
1920e750d362        24 seconds ago      /bin/sh -c if [ -s /.files-to-remove.list ];    0 B
1267bf926729        4 seconds ago       /bin/sh -c #(nop) ADD file:5021c627243e841a45   19 B
d04a2181b62a        2 minutes ago       /bin/sh -c #(nop) ADD file:14780990c926e673f2   264 B
d4b30af167f4        7 minutes ago       /bin/sh -c #(nop) COPY dir:68b8f374d8731b8ad8   16.78 MB
c898fe1daa44        9 minutes ago       /bin/sh -c apt-get update && apt-get install    10.77 MB
39a8a358844a        4 months ago        /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B
b1dacad9c5c9        4 months ago        /bin/sh -c #(nop) ADD file:5afd8eec1dc1e7666d   125.1 MB
```

Verify that the processed new image contains the same contents as the original:

```
export RESTRICT_DIFF_TO_PATH=/app
export OLD_IMAGE=sample-project:revision-2
export NEW_IMAGE=sample-project:revision-2-processed
docker-compose -f rsync-image-diff.docker-compose.yml up
```

The output should indicate that there are no differences between the images/tags. Thus, the sample-project:revision-2-processed tag can now be pushed and deployed, leading to the same end result but without having to push an unnecessary 16.78M over the wire, leading to faster deploy cycles.
