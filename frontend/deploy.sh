#!/bin/bash



if [ $# -eq 0 ]; then
	echo "Error, no color specified. \nUsage: \n\tsh deploy.sh green\n\nExiting."
	exit 1
fi

color=$1

docker-compose stop flask-$color
docker-compose rm -f flask-$color
docker-compose pull flask-$color
docker-compose create --force-recreate flask-$color
docker-compose up -d --force-recreate flask-$color
    