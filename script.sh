#!/bin/bash

docker-machine create -d virtualbox \
        --virtualbox-memory "2000" \
        --engine-opt="label=com.function=consul" \
        keystore

eval $(docker-machine env keystore)

docker run --restart=unless-stopped -d -p 8500:8500 -h consul progrium/consul -server -bootstrap

echo "====== KEYSTORE CLUSTER SET UP COMPLETE ====="

docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-manager" swarm0

eval $(docker-machine env swarm0)

docker run -d -p 4000:4000 -v /var/lib/boot2docker:/certs:ro swarm manage -H :4000 \
        --tlsverify \
        --tlscacert=/certs/ca.pem \
        --tlscert=/certs/server.pem \
        --tlskey=/certs/server-key.pem \
        --replication --advertise $(docker-machine ip swarm0):4000 \
        consul://$(docker-machine ip keystore):8500


echo "====== SWARM MANAGER SET UP COMPLETE ====="

docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-node" node0

eval $(docker-machine env node0)

docker run -d swarm join --advertise=$(docker-machine ip node0):2376 consul://$(docker-machine ip keystore):8500

HOST_IP=$(docker-machine ip node0)

docker run -d \
        --name=registrator \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        gliderlabs/registrator:latest \
        -ip $HOST_IP \
        consul://$(docker-machine ip keystore):8500


echo "====== NODE 0 SET UP COMPLETE ====="

docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-node" node1

eval $(docker-machine env node1)
docker run -d swarm join --advertise=$(docker-machine ip node1):2376 consul://$(docker-machine ip keystore):8500

HOST_IP=$(docker-machine ip node1)


docker run -d \
        --name=registrator \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        gliderlabs/registrator:latest \
        -ip $HOST_IP \
        consul://$(docker-machine ip keystore):8500

echo "====== NODE 1 SET UP COMPLETE ====="

echo "\n\nStarting loadbalancer...\n"

docker-machine create -d virtualbox --engine-opt="label=com.function=loadbalancer0" loadbalancer0

eval $(docker-machine env loadbalancer0)

cd lb
docker build -t jonasmunck/loadbalancer .

echo "====== LOADBALANCER HOST RUNNING =====\n\n"

echo "Copy and paste command below to enter swarm manager mode:"
echo "export DOCKER_HOST=$(docker-machine ip swarm0):4000"


### 
#
# Start loadbalancer 
# cd /Users/JonasMunck/programming/consul-lek/lb
# docker run --rm -it -v /Users/JonasMunck/programming/consul-lek/lb/templates:/templates -p 80:80 jonasmunck/loadbalancer /bin/bash
# consul-template -consul 192.168.99.101:8500 -template "/templates/canary.tmpl:/etc/nginx/conf.d/service.conf:service nginx restart" -dry -once




