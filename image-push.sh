#!/bin/bash
# using docker due to podman bugs

export OPENWHISK_VERSION=rhdemo-9717f07a
export PROJECTODD_VERSION=8ee5579
export STRIMZI_VERSION="0.3.1"
export ALARMPROVIDER_VERSION="1.9.0"
export NGINX_VERSION="42330f7f29ba1ad67819f4ff3ae2472f62de13a827a74736a5098728462212e7"
export REGISTRY="172.30.1.1:5000"

# create the `ocf-infra` project
oc new-project ocf-infra

# login to the registry with its builder account
docker login -u serviceaccount -p `oc sa get-token builder -n ocf-infra` $REGISTRY

# load all the tarballs into the local docker image store
for tarball in `ls projectodd*`
do
  docker load -i $tarball
done

# retag images with `whisky` tag
for image in \
action-nodejs-6 \
action-nodejs-8 \
action-java-8 \
action-python-3 \
action-python-2 \
action-php-7 \
dockerskeleton
do
  docker tag docker.io/projectodd/$image:$PROJECTODD_VERSION $REGISTRY/ocf-infra/$image:whisky
done
for image in \
controller \
invoker
do
  docker tag docker.io/projectodd/$image:$OPENWHISK_VERSION $REGISTRY/ocf-infra/$image:whisky
done
docker tag docker.io/strimzi/cluster-controller:$STRIMZI_VERSION $REGISTRY/ocf-infra/cluster-controller:whisky
docker tag docker.io/openwhisk/alarmprovider:$ALARMPROVIDER_VERSION $REGISTRY/ocf-infra/alarmprovider:whisky
docker tag docker.io/centos/nginx-112-centos7@sha256:$NGINX_VERSION $REGISTRY/ocf-infra/nginx:whisky
docker tag docker.io/busybox:latest $REGISTRY/ocf-infra/busybox:whisky
docker tag docker.io/projectodd/whisk_couchdb:$PROJECTODD_VERSION $REGISTRY/ocf-infra/couchdb:whisky
docker tag docker.io/projectodd/whisk_alarms:$PROJECTODD_VERSION $REGISTRY/ocf-infra/alarms:whisky
docker tag docker.io/projectodd/whisk_catalog:$PROJECTODD_VERSION $REGISTRY/ocf-infra/catalog:whisky

# find all the images we re-tagged and then push them into the registry
for image in $(docker images | grep 172 | awk '{print $1":"$2}')
do
  docker push $image
done

# patch the imagestreams to change the lookup policy
for stream in $(oc get is -o name)
do 
  oc patch $stream -p '{"spec":{"lookupPolicy":{"local":true}}}'
done