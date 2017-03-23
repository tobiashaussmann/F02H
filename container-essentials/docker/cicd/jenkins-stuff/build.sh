#!/bin/bash

if [ -z "${1}" ]; then
    version="latest"
else
    version="${1}"
fi

cd /var/jenkins_data/
docker build -t localhost:5000/containersol/my_nodejs_image:${version} -f Dockerfile.nodejs --no-cache .
cd ..