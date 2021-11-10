#!/bin/sh
docker build -t lfs:dev .
docker rm lfs
docker run -it --name lfs lfs:dev /bin/true
echo "Built system!"

rm -rf out
docker cp lfs:/out out
echo "Copied system to out!"
