#!/bin/sh
exec 2>&1
exec /sbin/setuser tmpuser /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties >> /tmp/runit_kafka.log 2>&1
