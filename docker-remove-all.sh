#!/bin/bash 
docker rm $(docker container ls -q --filter status='exited')
