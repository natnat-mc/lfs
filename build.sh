#!/bin/sh
echo "Building system"
docker build -t lfs:dev .
docker rm lfs
docker run -it --name lfs lfs:dev /bin/true

echo "Copying system outside of docker"
rm -rf out
docker cp lfs:/out out

echo "Done!"
