#!/bin/sh
exec 2>&1
exec /sbin/setuser tmpuser /opt/cassandra/bin/cassandra -f >> /tmp/runit_cassandra.log 2>&1
