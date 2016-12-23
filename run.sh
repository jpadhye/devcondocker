#!/bin/bash

set -e 
set -x

open -a XQuartz
IP=$(ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}')
xhost + $IP
docker run -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix -h devcondocker --name devcondocker -itd devcondocker
