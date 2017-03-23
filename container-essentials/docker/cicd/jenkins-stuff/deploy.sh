#!/bin/bash

if [ -z "${1}" ]; then
    version="latest"
else
    version="${1}"
fi

docker ps -a | awk '{ print $1,$2 }' | grep my_nodejs_image | awk '{print $1 }' | xargs -I {} docker rm -f {}
docker run -d -p 8000:8000 localhost:5000/containersol/my_nodejs_image:${version}