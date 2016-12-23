FROM phusion/baseimage:0.9.19
MAINTAINER Jaideep Padhye
LABEL Description="Development container: JDK, Kafka, Cassandra, Zookeeper and Eclipse"

ARG USERID
ARG GROUPID
ARG USERNM 

RUN apt-get update && apt-get install -y sudo

RUN echo "Adding user ${USERNM}:${USERID}:${GROUPID}"
#Add local non-root user with same UID and GID as the Docker Host user. Make the login passwordless.
RUN adduser --shell /bin/bash --uid ${USERID} --gid ${GROUPID} --disabled-password --gecos '' ${USERNM}
RUN adduser ${USERNM} sudo 
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${USERNM} 
ENV HOME /home/${USERNM}

#Install JAVA repo and upgrade distribution
RUN sudo sed 's/main$/main universe/' -i /etc/apt/sources.list && \
                sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && \
                sudo add-apt-repository -y ppa:webupd8team/java && \
                sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

#Basic system
RUN sudo apt-get install -y --no-install-recommends \
                       apt-utils \
                       software-properties-common \
                       build-essential \
                       oracle-java8-installer \
                       oracle-java8-set-default \
                       libprotobuf* \
                       protobuf* \
                       ca-certificates \
                       tree \
                       curl \
                       dstat \
                       expect \
                       ethtool \
                       git \
                       libjemalloc1 \
                       libev4 \
                       libxtst6 \
                       libgtk2.0-0 \
                       make \
                       maven \
                       net-tools \
                       python-pip \
                       python-setuptools \
                       sysstat \
                       unzip \
                       vim \
                       wget \
                       gnupg \
                       dnsutils \
                       scala \
                       zip && \
                       sudo rm -rf /var/cache/oracle-jdk8-installer && \
                       export JAVA_HOME=/usr/lib/jvm/java-8-oracle

#Prepare directory to receive packages
ENV PACKAGE_HOME $HOME/packages
RUN mkdir -p $PACKAGE_HOME

#Install Zookeeper
ENV ZOO_VERSION "3.4.9"
ENV ZOO_HOME "/opt/zookeeper"
ENV ZOO_TAR zookeeper-"$ZOO_VERSION".tar.gz
RUN wget -q http://apache.mirrors.spacedump.net/zookeeper/zookeeper-$ZOO_VERSION/$ZOO_TAR -O /tmp/$ZOO_TAR 
RUN tar -zxf /tmp/$ZOO_TAR -C $PACKAGE_HOME/ && \
             sudo ln -s $PACKAGE_HOME/zookeeper-"$ZOO_VERSION" $ZOO_HOME && \
             sudo chown -R $USERNM: $ZOO_HOME $PACKAGE_HOME/zookeeper-"$ZOO_VERSION" && \
             rm /tmp/$ZOO_TAR && \
             echo "tickTime=2000\ndataDir=/opt/zookeeper/data\nclientPort=2181" > $ZOO_HOME/conf/zoo.cfg 
RUN sudo mkdir -p /etc/service/zookeeper 
ADD configs/zookeeper.sh /etc/service/zookeeper/run
RUN sudo chmod a+x /etc/service/zookeeper/run && \
    sudo sed -i -e 's/tmpuser/'$USERNM'/g' /etc/service/zookeeper/run
EXPOSE 2181 

#Install Kafka
ENV SCALA_VERSION "2.11"
ENV KAFKA_VERSION "0.10.1.0"
ENV KAFKA_HOME "/opt/kafka"
ENV KAFKA_TAR kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz
RUN wget -q http://apache.mirrors.spacedump.net/kafka/$KAFKA_VERSION/$KAFKA_TAR -O /tmp/$KAFKA_TAR
RUN tar -zxf /tmp/$KAFKA_TAR -C $PACKAGE_HOME/ && \
             sudo ln -s $PACKAGE_HOME/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION" $KAFKA_HOME && \
             sudo chown -R $USERNM: $KAFKA_HOME $PACKAGE_HOME/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION" && \
             rm /tmp/$KAFKA_TAR
RUN sudo mkdir -p /etc/service/kafka 
ADD configs/kafka.sh /etc/service/kafka/run
RUN sudo chmod a+x /etc/service/kafka/run && \
    sudo sed -i -e 's/tmpuser/'$USERNM'/g' /etc/service/kafka/run
EXPOSE 9092


#Install Cassandra
ENV CASSANDRA_VERSION "3.9"
ENV CASSANDRA_HOME "/opt/cassandra"
ENV CASSANDRA_TAR apache-cassandra-"$CASSANDRA_VERSION"-bin.tar.gz
RUN wget -q  http://www-us.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz -O /tmp/$CASSANDRA_TAR
RUN tar -zxf /tmp/$CASSANDRA_TAR -C $PACKAGE_HOME/ && \
             sudo ln -s $PACKAGE_HOME/apache-cassandra-$CASSANDRA_VERSION $CASSANDRA_HOME && \
             sudo chown -R $USERNM: $CASSANDRA_HOME $PACKAGE_HOME/apache-cassandra-$CASSANDRA_VERSION && \
             mkdir -p $CASSANDRA_HOME/data/{data,commitlog,saved_caches} $CASSANDRA_HOME/logs && \
             rm /tmp/$CASSANDRA_TAR
RUN sudo mkdir -p /etc/service/cassandra 
ADD configs/cassandra.sh /etc/service/cassandra/run
RUN sudo chmod a+x /etc/service/cassandra/run && \
    sudo sed -i -e 's/tmpuser/'$USERNM'/g' /etc/service/cassandra/run
EXPOSE 7199 7000 7001 9160 9042

#Install other usesful software


# Download code. Here I'm downloading samples for JavaEE8 as an example. Replace the last line with your repository
RUN mkdir $HOME/.ssh/
ADD keys/id_rsa $HOME/.ssh/id_rsa
RUN sudo chown -R $USERNM: $HOME
RUN chmod 700 $HOME/.ssh && chmod 600 $HOME/.ssh/id_rsa
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> $HOME/.ssh/config
RUN cd $HOME && git clone https://github.com/javaee-samples/javaee8-samples.git

#Install Eclipse
ENV ECLIPSE_HOME "opt/eclipse"
ENV ECLIPSE_URL "http://eclipse.mirror.rafal.ca/technology/epp/downloads/release/neon/2.RC3/eclipse-java-neon-2-RC3-linux-gtk-x86_64.tar.gz"
ADD configs/eclipse.desktop /usr/share/applications/eclipse.desktop
RUN wget -q "$ECLIPSE_URL"  -O /tmp/eclipse.tar.gz
RUN tar xvf /tmp/eclipse.tar.gz -C $PACKAGE_HOME && \
        sudo ln -s $PACKAGE_HOME/eclipse $ECLIPSE_HOME && \
        sudo chown -R $USERNM: $ECLIPSE_HOME $PACKAGE_HOME/eclipse && \
        chmod +x $ECLIPSE_HOME/eclipse && \
        rm /tmp/eclipse.tar.gz



# Cleanup
RUN sudo apt-get autoremove -y && sudo apt-get clean && \
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER root

ENTRYPOINT ["/sbin/my_init"]
