#!/bin/bash

eval $(docker-machine env loadbalancer0)


docker run -d -p 80:80 -v /Users/JonasMunck/programming/consul-lek/lb/templates:/templates jonasmunck/loadbalancer
