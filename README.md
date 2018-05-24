# Node-RED-homekit-docker

[![Greenkeeper badge](https://badges.greenkeeper.io/RaymondMouthaan/node-red-homekit-docker.svg)](https://greenkeeper.io/)
[![Build Status](https://travis-ci.org/RaymondMouthaan/node-red-homekit-docker.svg?branch=master)](https://travis-ci.org/RaymondMouthaan/node-red-homekit-docker)
[![DockerHub Pull](https://img.shields.io/docker/pulls/raymondmm/node-red-homekit.svg)](https://hub.docker.com/r/raymondmm/node-red-homekit/)

Node-RED-homekit is a Node-RED based project with support for homekit. It contains the necessary tools to run homekit within a docker container and has the npm module [node-red-contrib-homekit-bridged](https://www.npmjs.com/package/node-red-contrib-homekit-bridged) installed.

## Architecture
Currently Node-RED-homekit has support for multiple architectures:
- amd64 : based on linux Alpine (i.e. Synology NAS)
- arm32v7 : based on linux Debian - (i.e. Raspberry PI3)
- arm64v8 : based on linux Alpine - (i.e. Pine64)

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

### Persistent (recommended)
Persistence is recommended to use, so one doesn't loose it's node-red data (flows etc) after a restart of the container. Follow the steps to persist the node-red data directory outside the container.

The Node-RED runs as user node-red. This user inside the container has uid 1001, which means this user needs write-access to `<path_on_your_host>`. To add a user with uid 1001 on the host, use:

```
sudo adduser --uid 1001 --no-create-home --disabled-password node-red
```

This command creates a user node-red on the host with uid 1001 without a home directory and without password.

The following two commands create a directory on the host and sets the ownership to user node-red:
```
mkdir <path_on_your_host>
chown -R node-red:node-red <path_on_your_host>
```

With this setup, one can execute the following command:
```
docker run -d --network host -e HOST_NAME=$HOSTNAME -v <path_on_your_host>:/data --name node-red-homekit raymondmm/node-red-homekit
```

### Stack
Todo
