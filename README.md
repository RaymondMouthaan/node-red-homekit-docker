# Node-RED-homekit-docker

[![Build Status](https://travis-ci.org/RaymondMouthaan/node-red-homekit-docker.svg?branch=master)](https://travis-ci.org/RaymondMouthaan/node-red-homekit-docker)
[![DockerHub Pull](https://img.shields.io/docker/pulls/raymondmm/node-red-homekit.svg)](https://hub.docker.com/r/raymondmm/node-red-homekit/)

Node-RED-homekit is a Node-RED based project with support for homekit. It contains the necessary tools to run homekit within a docker container and has the npm module [node-red-contrib-homekit-bridged](https://www.npmjs.com/package/node-red-contrib-homekit-bridged) installed.

## Architecture
Currently Node-RED-homekit has support for multiple architectures, which are:
- amd64 : based on linux Alpine (i.e. Synology NAS)
- arm32v7 : based on linux Debian - (i.e. Raspberry PI3)

## Usage
Some basic familiarity with Docker and the [Docker Command Line](https://docs.docker.com/engine/reference/commandline/cli/) is assumed.

Node-RED-homekit is supported by manifest list, which means one doesn't need to specify the tag for a specific architecture. Using the image without any tag or the latest tag , will pull the right image for the architecture required.

### Quick Start

```
docker run -d --network host -e HOST_NAME=myhostname --name myhomekit raymondmm/node-red-homekit
```

Let's dissect that command:

    docker run                 - Run this container... and build locally if necessary first.
    -d                         - Run container in background and print container ID.
    --network host             - Connect to the host network, which is required to work with homekit.
    -e HOST_NAME=myhostname    - Set the environment variable HOST_NAME to the hostname of host.
    --name mynodered           - Give this machine a friendly local name.
    raymondmm/node-red-homekit - The image to base it.

The command doesn't have a tag defined in the image. This means it pulls the lastest. When running on a amd64 system, docker pulls corresponding image for it. The same applies for running on a arm32v7 system.

The hostname can be found using the following command on the host:
```
echo $HOSTNAME
```

Just to make a live a little more easier, take both commands together:
```
docker run -d --network host -e HOST_NAME=$HOSTNAME --name myhomekit raymondmm/node-red-homekit
```

By default Node-RED runs on port 1880, so after deploying the node-red-homekit container it listens on port 1880. Open up a browser to `http://<your_server>:1880`, which opens the node-red web interface.
