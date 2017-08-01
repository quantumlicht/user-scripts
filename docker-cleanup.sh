#!/bin/sh

docker volume rm $(docker volume ls -qf dangling=true) && \
docker rmi -f $(docker images -qf dangling=true) && \
docker rm $(docker ps -q -f 'status=exited') && \
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

