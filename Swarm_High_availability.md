Swarm High availability

_This guide assumes that you have a consul server up'n'running on a docker machine named **keystore**_

Three machines

swarm-1
swarm-2
swarm-3

	docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-manager" swarm-1

	docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-manager" swarm-2

	docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-manager" swarm-3


Create managers in HA swarm cluser

	eval $(docker-machine env swarm-1)

	docker run -d -p 4000:4000 -v /var/lib/boot2docker:/certs:ro swarm manage -H :4000 \
		--tlsverify \
		--tlscacert=/certs/ca.pem \
		--tlscert=/certs/server.pem \
		--tlskey=/certs/server-key.pem \
		--replication --advertise $(docker-machine ip swarm0):4000 \
		consul://$(docker-machine ip keystore1):8500

	eval $(docker-machine env swarm-2)

	docker run -d -p 4000:4000 -v /var/lib/boot2docker:/certs:ro swarm manage -H :4000 \
		--tlsverify \
		--tlscacert=/certs/ca.pem \
		--tlscert=/certs/server.pem \
		--tlskey=/certs/server-key.pem \
		--replication --advertise $(docker-machine ip swarm-2):4000 \
		consul://$(docker-machine ip keystore1):8500


	eval $(docker-machine env swarm-3)

	docker run -d -p 4000:4000 -v /var/lib/boot2docker:/certs:ro swarm manage -H :4000 \
		--tlsverify \
		--tlscacert=/certs/ca.pem \
		--tlscert=/certs/server.pem \
		--tlskey=/certs/server-key.pem \
		--replication --advertise $(docker-machine ip swarm-3):4000 \
		consul://$(docker-machine ip keystore1):8500


Join nodes

docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-node" node0
docker-machine create -d virtualbox --engine-opt="label=com.function=swarm-node" node1

eval $(docker-machine env node1)
docker run -d swarm join --advertise=$(docker-machine ip node1):2376 consul://$(docker-machine ip keystore):8500

eval $(docker-machine env node0)
docker run -d swarm join --advertise=$(docker-machine ip node0):2376 consul://$(docker-machine ip keystore):8500


