#!/bin/sh
# docker system prune -a
volumes=$(docker volume ls -qf dangling=true)
echo "volumes: [${volumes}]"
if [ "$volumes" ]; then
  docker volume rm $volumes
fi

images=$(docker images -qf dangling=true)
echo "images: [$images]"
if [ "$images" ]; then
  docker rmi -f $images
fi

exited_processes=$(docker ps -q -f 'status=exited')
echo "exited_processes: [$exited_processes]"
if [ "$exited_processes" ]; then
  docker rm $exited_processes
fi

none_images=$(docker images | grep "^<none>" | awk "{print $3}")
echo "none images: [$none_images]"
if [ "$none_images" ]; then
  docker rmi $none_images
fi


docker rm $(docker ps -a -q)

