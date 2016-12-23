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

Solution has been tested on MacOS 10.12.2.

##Usage: 
1. Modify the dockerfile to install your selected dependencies and download your code.
2. Put your private key in the keys folder to allow download of code. Make sure public key is installed in ssh server.
3. Install Xquartz(> 2.7.11) and Docker for Mac(> 1.12.5) and run `./build.sh` 
4. Correctly setup permissions on Xquartz :
   ![XQuartz Preferences](/docs/xquartz.png)
5. Run `./run.sh`
6. Connect to the container and execute eclipse
```jpadhye@JPADHYE-M-419M:~/devcondocker (master) $ ./run.sh 
+ open -a XQuartz
++ ifconfig en0
++ grep inet
++ grep -v inet6
++ awk '{print $2}'
+ IP=192.168.2.194
+ xhost + 192.168.2.194
192.168.2.194 being added to access control list
+ docker run -e DISPLAY=192.168.2.194:0 -v /tmp/.X11-unix:/tmp/.X11-unix -h devcondocker --name devcondocker -itd devcondocker
78797c14095c824b3c407948e4db360cea341c989dd92c37ce949332faa4ab61
jpadhye@JPADHYE-M-419M:~/devcondocker (master) $ docker exec -u $USER -it devcondocker bash -l
jpadhye@devcondocker:/$ /opt/eclipse/eclipse 
org.eclipse.m2e.logback.configuration: The org.eclipse.m2e.logback.configuration bundle was activated before the state location was initialized.  Will retry after the state location is initialized.```

Some helpful docker commands:

1. Build the container  : `docker build --build-arg USERID=`id -u $USER` --build-arg GROUPID=`id -g $USER` --build-arg USERNM=$USER -t devcondocker .`
2. Execute the container: `docker run -h devcondocker --name devcondocker -itd devcondocker`
3. Connect to container : `docker exec -u $USER -it devcondocker bash -l`
4. Remove stale containers: `docker rm $(docker ps -qa --no-trunc --filter "status=exited")`
5. Remove stale images: `docker rmi $(docker images --filter "dangling=true" -q --no-trunc)`


##Troubleshooting

1. ##Problem 1: 

~/devcondocker (master) $ ./run.sh 
+ open -a XQuartz
++ ifconfig en0
++ grep inet
++ grep -v inet6
++ awk '{print $2}'
+ IP=192.168.2.194
+ xhost + 192.168.2.194
xhost:  unable to open display "/private/tmp/com.apple.launchd.x8oFK5alZM/org.macosforge.xquartz:0"

Solution: 

1. Restart the system. If this doesn't work do step 2 and repeat this step.
2. brew cask uninstall xquartz && sudo rm -rf /opt/X11* /Library/Launch*/org.macosforge.xquartz.* /Applications/Utilities/XQuartz.app /etc/*paths.d/*XQuartz  ~/.serverauth*  ~/.Xauthorit*  ~/.cache  ~/.rnd  ~/Library/Caches/org.macosforge.xquartz.X11 ~/Library/Logs/X11 /private/tmp/com.apple.launchd.* 




	
## NOTE: This project is a toy and by no means is proper way of using any of the software being used. This servers my limited purpose. You are welcome to make imporvements as your like.
