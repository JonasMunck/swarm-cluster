#!/bin/bash

DOCKER_HOST=$(docker-machine ip swarm0):4000

echo $DOCKER_HOST
