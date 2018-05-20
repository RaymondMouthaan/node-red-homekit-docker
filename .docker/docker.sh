#!/bin/bash
set -o errexit

main() {
    case $1 in
        "prepare")
            docker_prepare
            ;;
        "build")
            docker_build
            ;;
        "test")
            docker_test
            ;;
        "tag")
            docker_tag
            ;;
        "push")
            docker_push
            ;;
        "manifest-list")
            docker_manifest_list
            ;;
        *)
            echo "none of above!"
    esac
}

docker_prepare() {
    # Prepare the machine before any code installation scripts
    setup_dependencies

    # Update docker configuration to enable docker manifest command
    update_docker_configuration

    # Prepare qemu to build non-x86_64 architectures on x86_64
    prepare_qemu
}

docker_build() {
    # Build all images
    echo "DOCKER BUILD: Build all docker images."
    docker build --build-arg NODE_RED_HOMEKIT_VERSION=$NODE_RED_HOMEKIT_VERSION --build-arg NODE_RED_IMAGE_TAG=$NODE_RED_VERSION-alpine-amd64   --build-arg QEMU_ARCH=x86_64 --file ./.docker/Dockerfile.alpine-tmpl --tag $IMAGE:build-$NODE_RED_VERSION-alpine-amd64 .
    #docker build --build-arg NODE_RED_HOMEKIT_VERSION=$NODE_RED_HOMEKIT_VERSION --build-arg NODE_RED_IMAGE_TAG=$NODE_RED_VERSION-debian-arm32v7 --build-arg QEMU_ARCH=arm    --file ./.docker/Dockerfile.debian-tmpl --tag $IMAGE:build-$NODE_RED_VERSION-debian-arm32v7 .
    # docker build --no-cache --build-arg NODE_RED_VERSION=v$NODE_RED_VERSION --build-arg ARCH=arm64v8 --build-arg NODE_IMAGE_TAG=8-alpine  --build-arg QEMU_ARCH=aarch64 --file ./.docker/Dockerfile.alpine-tmpl --tag $IMAGE:build-8-alpine-arm64v8 .
}

docker_test() {
    # Test all images
    echo "DOCKER TEST: Test all docker images."

    docker run -d --rm --name=test-$NODE_RED_VERSION-alpine-amd64 $IMAGE:build-$NODE_RED_VERSION-alpine-amd64
    if [ $? -ne 0 ]; then
       echo "DOCKER TEST: FAILED - Docker container failed to start for build-$NODE_RED_VERSION-alpine-amd64."
       exit 1
    else
       echo "DOCKER TEST: PASSED - Docker container succeeded to start for build-$NODE_RED_VERSION-alpine-amd64."
    fi

    # docker run -d --rm --name=test-$NODE_RED_VERSION-debian-arm32v7 $IMAGE:build-$NODE_RED_VERSION-debian-arm32v7
    # if [ $? -ne 0 ]; then
    #     echo "DOCKER TEST: FAILED - Docker container failed to start for build-$NODE_RED_VERSION-debian-arm32v7."
    #     exit 1
    # else
    #     echo "DOCKER TEST: PASSED - Docker container succeeded to start for build-$NODE_RED_VERSION-debian-arm32v7."
    # fi
}

docker_tag() {
    # Tag all images
    echo "DOCKER TAG: Tag all docker images."
    docker tag $IMAGE:build-$NODE_RED_VERSION-alpine-amd64 $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-alpine-amd64
    #docker tag $IMAGE:build-$NODE_RED_VERSION-debian-arm32v7 $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7
}

docker_push() {
    # Push all images
    echo "DOCKER PUSH: Push all docker images."
    docker push $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-alpine-amd64
    #docker push $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7
}

docker_manifest_list() {
    # Create and push manifest lists, displayed as FIFO
    echo "DOCKER MANIFEST: Create and Push docker manifest list."
    docker_manifest_list_version
    docker_manifest_list_latest
}

docker_manifest_list_version() {
    # Manifest Create NODE_RED_HOMEKIT_VERSION
    echo "DOCKER MANIFEST: Create and Push docker manifest list - $NODE_RED_HOMEKIT_VERSION."
    docker manifest create $IMAGE:$NODE_RED_HOMEKIT_VERSION \
        $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-alpine-amd64 #\
        #$IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7

    # Manifest Annotate NODE_RED_VERSION
    #docker manifest annotate $IMAGE:$NODE_RED_HOMEKIT_VERSION $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7 --os=linux --arch=arm --variant=v7

    # Manifest Push NODE_RED_VERSION
    docker manifest push $IMAGE:$NODE_RED_HOMEKIT_VERSION
}

docker_manifest_list_latest() {
    # Manifest Create latest
    echo "DOCKER MANIFEST: Create and Push docker manifest list - latest."
    docker manifest create $IMAGE:latest \
        $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-alpine-amd64 #\
        #$IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7
        # $IMAGE:latest-8-alpine-arm64v8

    # Manifest Annotate latest
    #docker manifest annotate $IMAGE:latest $IMAGE:$NODE_RED_HOMEKIT_VERSION-$NODE_RED_VERSION-debian-arm32v7 --os=linux --arch=arm --variant=v7

    # Manifest Push latest
    docker manifest push $IMAGE:latest
}

setup_dependencies() {
  echo "PREPARE: Setting up dependencies."

  sudo apt update -y
  #sudo apt upgrade -y
  # sudo apt install realpath python python-pip -y
  sudo apt install --only-upgrade docker-ce -y
  # sudo pip install docker-compose || true

  docker info
  # docker-compose --version
}

update_docker_configuration() {
  echo "PREPARE: Updating docker configuration"

  mkdir $HOME/.docker

  # enable experimental to use docker manifest command
  echo '{
    "experimental": "enabled"
  }' | tee $HOME/.docker/config.json

  # enable experimental
  echo '{
    "experimental": true,
    "storage-driver": "overlay2",
    "max-concurrent-downloads": 50,
    "max-concurrent-uploads": 50
  }' | sudo tee /etc/docker/daemon.json

  sudo service docker restart
}

prepare_qemu(){
    echo "PREPARE: Qemu"
    # Prepare qemu to build non amd64 / x86_64 images
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
    mkdir tmp
    pushd tmp &&
    curl -L -o qemu-x86_64-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/$QEMU_VERSION/qemu-x86_64-static.tar.gz && tar xzf qemu-x86_64-static.tar.gz &&
    curl -L -o qemu-arm-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/$QEMU_VERSION/qemu-arm-static.tar.gz && tar xzf qemu-arm-static.tar.gz &&
    curl -L -o qemu-aarch64-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/$QEMU_VERSION/qemu-aarch64-static.tar.gz && tar xzf qemu-aarch64-static.tar.gz &&
    popd
}

main $1
