#!/bin/bash


# Restart and regenerate certificates for all docker host
declare -a arr=("keystore" "loadbalancer0" "swarm0" "node0" "node1")

for i in "${arr[@]}"
do
	docker-machine restart $i
	docker-machine regenerate-certs -f $i
done


echo "Starting swarm manager application"

eval $(docker-machine env swarm0)

docker rm -f $(docker ps -a -q)

docker run -d -p 4000:4000 -v /var/lib/boot2docker:/certs:ro swarm manage -H :4000 \
        --tlsverify \
        --tlscacert=/certs/ca.pem \
        --tlscert=/certs/server.pem \
        --tlskey=/certs/server-key.pem \
        --replication --advertise $(docker-machine ip swarm0):4000 \
        consul://$(docker-machine ip keystore):8500

echo "-----------------------\n\n"        

declare -a nodes=("node0" "node1")

for j in "${nodes[@]}"
do
	echo "Entering ${j}"
	eval $(docker-machine env ${j})
	docker rm -f $(docker ps -a -q)
	echo "All containers deleted"
	docker run -d swarm join --advertise=$(docker-machine ip ${j}):2376 consul://$(docker-machine ip keystore):8500
	echo "Swarm joined"

	HOST_IP=$(docker-machine ip ${j})

	docker run -d \
	        --name=registrator \
	        --volume=/var/run/docker.sock:/tmp/docker.sock \
	        gliderlabs/registrator:latest \
	        -ip $HOST_IP \
	        consul://$(docker-machine ip keystore):8500

	echo "Registrator running"
	echo "-----------------------\n\n"        

done