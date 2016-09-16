Orchestration 2.0
=================

## Definitions

node - a computer which runs application code



### Create Consul cluser

_Currently only one server, not HA_

Create a docker host, _keystore_, that will run a single consul server.

	docker-machine create -d virtualbox 
		--virtualbox-memory "2000" 
		--engine-opt="label=com.function=consul"  
		keystore

Point your docker host to the new host.

	eval $(docker-machine env keystore)

Start the consul server

	docker run --restart=unless-stopped -d -p 8500:8500 -h consul progrium/consul -server -bootstrap


and check that Consul is up'n'running

	curl $(docker-machine ip keystore):8500/v1/catalog/nodes


### Create swarm manager

The swarm manager has control over the nodes in the microservice cluster.
Once again this is a development setup, with just one manager. In a High Availabilty setup
this should be a cluser of managers (with a primary manager and several redundant, secondary, managers).

	docker-machine create -d virtualbox \
		--swarm \
		--swarm-master  \
		--swarm-discovery="consul://$(docker-machine ip keystore):8500"  \
		--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500"  \
		--engine-opt="cluster-advertise=eth1:2376" \
		manager-1


### Start swarm manager

	eval $(docker-machine env manager-1)

	docker run --restart=unless-stopped -d -p 3376:2375 -v /var/lib/boot2docker:/certs:ro swarm manage  \
		--tlsverify \
		--tlscacert=/certs/ca.pem \
		--tlscert=/certs/server.pem \
		--tlskey=/certs/server-key.pem \
		consul://$(docker-machine ip keystore):8500


### Creat a node

Create a docker host which will function as a node. It connects to the swarm manager via consul. 

	docker-machine create -d virtualbox  \
		--swarm     \
		--swarm-discovery="consul://$(docker-machine ip keystore):8500"     \
		--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500"     \
		--engine-opt="cluster-advertise=eth1:2376" 	\
		frontend0

### Join swarm

	eval $(docker-machine env frontend0)
	docker run -d swarm join --addr=$(docker-machine ip frontend0):2376 consul://$(docker-machine ip keystore):8500

### Get some information of the current state

	docker -H $(docker-machine ip manager-1):3376 info

### Consul automatic service

##### Registrator

Per node (example: frontend0)

	eval $(docker-machine env frontend0)

need to use the -ip flag since everything is on local machine

	docker run -d \
	    --name=registrator \
	    --volume=/var/run/docker.sock:/tmp/docker.sock \
	    gliderlabs/registrator:latest \
	    -ip NODE_IP \
	    consul://$(docker-machine ip keystore1):8500


### Add a loadbalancer

Nginx, not High Availablity


	docker-machine create -d virtualbox --engine-opt="label=com.function=loadbalancer" loadbalancer0

	docker build -t jonasmunck/loadbalancer .

	eval $(docker-machine env loadbalancer0)


Use Dockerfile in ./lb, nginx with Consul-template


		
	docker-compose up -d lb




##### Consul-template

Our best friend!

	consul-template -consul 192.168.99.100:8500 -template "/templates/service.tmpl:/etc/nginx/conf.d/service.conf:service nginx restart" -dry -once

### Docker Compose

docker compose and docker swarm is <3 <3 <3

push the image to your registry to enable smooth scaling (swarm must download the image to be able to use scaling)




## Resources 

http://gliderlabs.com/registrator/latest/











