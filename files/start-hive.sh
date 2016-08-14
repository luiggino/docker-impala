#!/bin/bash

sed -i "s/__HOSTNAME__/$(hostname -i)/" /etc/hive/conf/hive-site.xml

service hive-metastore start
service hiveserver start
