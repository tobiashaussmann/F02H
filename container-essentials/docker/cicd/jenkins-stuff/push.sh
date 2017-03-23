#!/bin/bash

if [ -z "${1}" ]; then
    version="latest"
else
    version="${1}"
fi

docker push localhost:5000/containersol/my_nodejs_image:${version}