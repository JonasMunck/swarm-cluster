#!/bin/bash

# deploy new node

node=$1

docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-node" $node

eval $(docker-machine env $node)
docker run -d swarm join --advertise=$(docker-machine ip $node):2376 consul://$(docker-machine ip keystore):8500

HOST_IP=$(docker-machine ip $node)


docker run -d \
        --name=registrator \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        gliderlabs/registrator:latest \
        -ip $HOST_IP \
        consul://$(docker-machine ip keystore):8500