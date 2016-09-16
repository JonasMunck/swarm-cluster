Docker SWARM
============


Skapa maskinerna

eval "$(docker-machine env dev)"
docker-compose up -d consul  <- predefined consul container

docker-machine create -d virtualbox local
eval "$(docker-machine env local)"

docker run swarm create

docker-machine create -d  virtualbox --swarm --swarm-master --swarm-discovery consul://192.168.99.101:8500 swarm-master

docker-machine create -d  virtualbox --swarm --swarm-discovery consul://192.168.99.101:8500 swarm-agent-00
docker-machine create -d  virtualbox --swarm --swarm-discovery consul://192.168.99.101:8500 swarm-agent-01


docker run -d -e constraint:node==swarm-master    --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest -ip 192.168.99.102  consul://192.168.99.101:8500/
docker run -d -e constraint:node==swarm-agent-00  --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest  -ip 192.168.99.103  consul://192.168.99.101:8500/
docker run -d -e constraint:node==swarm-agent-01  --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest  -ip 192.168.99.104 consul://192.168.99.101:8500/



### On AWS


    (local) $ docker run swarm create

swarm token: 969f889cbf817bab55e8bc31555f618c

    docker-machine -D create                                        \
      --driver amazonec2                                            \
      --amazonec2-access-key $AWS_ACCESS_KEY_ID                     \
      --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY                 \
      --amazonec2-vpc-id $AWS_VPC_ID                                \
      --amazonec2-region eu-west-1                                  \
      --amazonec2-instance-type t2.nano                             \
      --amazonec2-security-group docker-machine                     \
      --swarm                                                       \
      --swarm-master                                                \
      --swarm-discovery=token://969f889cbf817bab55e8bc31555f618c    \
      aws-swarm-master

      docker-machine -D create                                        \
        --driver amazonec2                                            \
        --amazonec2-access-key $AWS_ACCESS_KEY_ID                     \
        --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY                 \
        --amazonec2-vpc-id $AWS_VPC_ID                                \
        --amazonec2-region eu-west-1                                  \
        --amazonec2-instance-type t2.nano                             \
        --amazonec2-security-group docker-machine                     \
        --swarm                                                       \
        --swarm-discovery=token://969f889cbf817bab55e8bc31555f618c    \
        aws-swarm-node-00

docker-machine -D create                                        \
  --driver amazonec2                                            \
  --amazonec2-access-key $AWS_ACCESS_KEY_ID                     \
  --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY                 \
  --amazonec2-vpc-id $AWS_VPC_ID                                \
  --amazonec2-region eu-west-1                                  \
  --amazonec2-instance-type t2.nano                             \
  --amazonec2-security-group docker-machine                     \
  --swarm                                                       \
  --swarm-discovery=token://969f889cbf817bab55e8bc31555f618c    \
  aws-swarm-node-02


Connect to the swarm

    $ eval $(docker-machine env --swarm aws-swarm-master)

    docker -H  tcp://54.194.255.114:2376 run -d swarm join --addr=54.194.255.114:2376 token://969f889cbf817bab55e8bc31555f618c


## Setup and start consul

#### master

docker run -d -h aws-swarm-master -v /mnt:/data \


docker -H tcp://54.229.79.220:2376 run -d \
    -p 172.31.29.180:8300:8300 \
    -p 172.31.29.180:8301:8301 \
    -p 172.31.29.180:8301:8301/udp \
    -p 172.31.29.180:8302:8302 \
    -p 172.31.29.180:8302:8302/udp \
    -p 172.31.29.180:8400:8400 \
    -p 172.31.29.180:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise 172.31.29.180 -bootstrap


#### nodes

###### aws-swarm-node-00

docker -H tcp://52.49.105.200:2376 run -d \
    -p 172.31.27.153:8300:8300 \
    -p 172.31.27.153:8301:8301 \
    -p 172.31.27.153:8301:8301/udp \
    -p 172.31.27.153:8302:8302 \
    -p 172.31.27.153:8302:8302/udp \
    -p 172.31.27.153:8400:8400 \
    -p 172.31.27.153:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul  -advertise 172.31.27.153 -join 172.31.29.180


###### aws-swarm-node-02
public  IP: 54.194.255.114
private IP: 172.31.17.146

docker -H tcp://54.194.255.114:2376 run -d   \
    -p 172.31.17.146:8300:8300 \
    -p 172.31.17.146:8301:8301 \
    -p 172.31.17.146:8301:8301/udp \
    -p 172.31.17.146:8302:8302 \
    -p 172.31.17.146:8302:8302/udp \
    -p 172.31.17.146:8400:8400 \
    -p 172.31.17.146:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -advertise 172.31.17.146 -join 172.31.29.180




docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap -ui-dir /ui


### registrator

  docker run -d -e constraint:node==aws-swarm-master  \
    --volume=/var/run/docker.sock:/tmp/docker.sock    \
    gliderlabs/registrator:latest  -ip 172.31.29.180 consul://172.31.29.180:8500/

    docker -H tcp://54.229.79.220:2376 run -d \
      --volume=/var/run/docker.sock:/tmp/docker.sock    \
      gliderlabs/registrator:latest  -ip 172.31.29.180 consul://172.31.29.180:8500/


  docker run -d -e constraint:node==aws-swarm-node-00  \
    --volume=/var/run/docker.sock:/tmp/docker.sock    \
    gliderlabs/registrator:latest -ip 172.31.27.153  consul://172.31.29.180:8500


  docker run -d -e constraint:node==aws-swarm-node-02 \
    --volume=/var/run/docker.sock:/tmp/docker.sock     \
    gliderlabs/registrator:latest -ip 172.31.17.146 consul://172.31.29.180:8500/


### remove stopped containers


docker -H tcp://54.229.79.220:2376 rm $(docker -H tcp://54.229.79.220:2376 ps -f status=exited -q)
docker -H tcp://54.229.246.76:2376 rm $(docker -H tcp://54.229.246.76:2376 ps -f status=exited -q)
docker -H tcp://54.194.255.114:2376 rm $(docker -H tcp://54.194.255.114:2376 ps -f status=exited -q)





### mongo

docker -H tcp://52.49.105.200:2376 run --name some-mongo -p 27017:27017 -v /mnt/mongodata:/data/configdb -d mongo

docker run --name db-mongo -d mongo




# upstream python-service {
#   least_conn;
#   {{range service "test"}}server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
#   {{else}}server 127.0.0.1:65535; # force a 502{{end}}
# }
#
# server {
#   listen 80 default_server;

#   charset utf-8;

#   location / {
#     proxy_pass http://python-service/$1$is_args$args;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
#   }
# }
