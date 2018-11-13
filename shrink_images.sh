cd docker-diff-based-layers
export RESTRICT_DIFF_TO_PATH=
export OLD_IMAGE=$1
export NEW_IMAGE=$2
docker-compose -f rsync-image-diff.docker-compose.yml up
docker-compose -f shell.docker-compose.yml -f process-image-diff.docker-compose.yml run --rm shell ./generate-dockerfile.sh

cd output; docker build -t $3 .; cd ..

cd ..