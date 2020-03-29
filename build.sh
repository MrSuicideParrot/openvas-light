#!/bin/sh

docker build -t cirne/openvas-light \
    --build-arg OPENVAS_VERSION=7.0.0 \
    --build-arg VERSION=1.0 \
    --build-arg GVM_LIBS_VERSION=11.0.0 \
    --build-arg GOCROND_VERSION=0.6.1 .
    --build-arg ARCH=64
