#!/bin/bash

set -e
set -x

if brew cask list | grep xquartz > /dev/null; then
  echo "XQuartz is installed"
else
  brew cask install xquartz
fi

if brew cask list | grep docker > /dev/null; then
  echo "Docker is installed"
else
  brew cask install docker
  echo "Run the docker GUI app. Confirm its in running state in taskbar and rerun this file."
  exit
fi


docker build --build-arg USERID=`id -u $USER` --build-arg GROUPID=`id -g $USER` --build-arg USERNM=$USER -t devcondocker .
