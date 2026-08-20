docker build --build-arg ALPINE_VERSION=3.24 --tag marchefter/alpine:3.24-networking --push image-networking
docker build --build-arg ALPINE_VERSION=latest --tag marchefter/alpine:networking --push image-networking

docker build --build-arg ALPINE_VERSION=3.24 --tag marchefter/alpine:3.24-appuser --push image-with-appuser
docker build --build-arg ALPINE_VERSION=latest --tag marchefter/alpine:appuser --push image-with-appuser
