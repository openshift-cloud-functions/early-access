#!/bin/bash
# temporarily using docker due to podman bugs

export OPENWHISK_VERSION=rhdemo-9717f07a
export PROJECTODD_VERSION=8ee5579
export STRIMZI_VERSION="0.3.1"
export ALARMPROVIDER_VERSION="1.9.0"
export NGINX_VERSION="42330f7f29ba1ad67819f4ff3ae2472f62de13a827a74736a5098728462212e7"
for image in \
action-nodejs-6 \
action-nodejs-8 \
action-java-8 \
action-python-3 \
action-python-2 \
action-php-7 \
dockerskeleton \
whisk_couchdb \
whisk_alarms \
whisk_catalog
do
  docker pull docker.io/projectodd/$image:$PROJECTODD_VERSION
  docker save -o projectodd-$image.tar docker.io/projectodd/$image:$PROJECTODD_VERSION
done
for image in \
controller \
invoker
do
  docker pull docker.io/projectodd/$image:$OPENWHISK_VERSION
  docker save -o projectodd-$image.tar docker.io/projectodd/$image:$OPENWHISK_VERSION
done
docker pull docker.io/strimzi/cluster-controller:$STRIMZI_VERSION
docker save -o projectodd-strimzi.tar docker.io/strimzi/cluster-controller:$STRIMZI_VERSION
docker pull docker.io/openwhisk/alarmprovider:$ALARMPROVIDER_VERSION
docker save -o projectodd-alarm.tar docker.io/openwhisk/alarmprovider:$ALARMPROVIDER_VERSION
docker pull docker.io/centos/nginx-112-centos7@sha256:$NGINX_VERSION
docker save -o projectodd-nginx.tar docker.io/centos/nginx-112-centos7@sha256:$NGINX_VERSION
docker pull docker.io/busybox
docker save -o projectodd-busybox.tar docker.io/busybox:latest