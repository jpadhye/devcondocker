# devcondocker
Development container with Ubuntu 16.04, Kafka, Cassandra, Zookeeper and Eclipse

##Problem Statement: 
I wanted to play around with Kafka, Zookeeper, Cassandra cluster and wanted to try out some Java APIs. I've my MacOS Sierra Macbook Pro and I did not want to install all the software as I was just trying out something. Usually I install Ubuntu VM but I thought it was too much pain and work. 

##Solution: 
Although it goes against Docker philosophy, I decided to try out if I can use a Docker container based development environment, as this is just for experimental purpose. I wrote this Dockerfile and it gives following things:
1. Ubuntu 16.04 based container.
2. Installation of Kafka, Zookeeper, Cassandra and Eclipse from source (without package manager)
3. Adds your keys and demonstrates how to download your source code
4. Sets up the contianer so that x11 could be forwarded to your host. This allows you to run eclipse and edit in on your mac.
5. Uses runit as the service manager for above services.


##Usage: 
1. Modify the dockerfile to install your selected dependencies and download your code.
2. Put your private key in the keys folder to allow download of code. Make sure public key is installed in ssh server.
3. Run `./build.sh && ./run.sh`


Some helpful docker commands:

1. Build the container  : `docker build --build-arg USERID=`id -u $USER` --build-arg GROUPID=`id -g $USER` --build-arg USERNM=$USER -t devcondocker .`
2. Execute the container: `docker run -h devcondocker --name devcondocker -itd devcondocker`
3. Connect to container : `docker exec -u `$USER` -it devcondocker bash -l`
4. Remove stale containers: `docker rm $(docker ps -qa --no-trunc --filter "status=exited")`
5. Remove stale images: `docker rmi $(docker images --filter "dangling=true" -q --no-trunc)`



##Problems

1. ~/devcondocker (master) $ ./run.sh 
+ open -a XQuartz
++ ifconfig en0
++ grep inet
++ grep -v inet6
++ awk '{print $2}'
+ IP=192.168.2.194
+ xhost + 192.168.2.194
xhost:  unable to open display "/private/tmp/com.apple.launchd.x8oFK5alZM/org.macosforge.xquartz:0"


Solution: 
a. brew cask uninstall xquartz && sudo rm -rf /opt/X11* /Library/Launch*/org.macosforge.xquartz.* /Applications/Utilities/XQuartz.app /etc/*paths.d/*XQuartz  ~/.serverauth*  ~/.Xauthorit*  ~/.cache  ~/.rnd  ~/Library/Caches/org.macosforge.xquartz.X11 ~/Library/Logs/X11 /private/tmp/com.apple.launchd.* 
b. Restart the system



	
## NOTE: This project is a toy and by no means is proper way of using any of the software being used. This servers my limited purpose. You are welcome to make imporvements as your like.
