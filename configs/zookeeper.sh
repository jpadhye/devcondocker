#!/bin/sh
exec 2>&1
exec /sbin/setuser tmpuser /opt/zookeeper/bin/zkServer.sh start-foreground >> /tmp/runit_zookeeper.log 2>&1
