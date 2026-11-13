#!/bin/bash

apt-get update
apt-get install -y openjdk-8-jdk wget

TOMCAT_VERSION=9.0.123

mkdir -p /opt/tomcat

wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz

tar -xzf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1

sed -i 's/port="8080"/port="7070"/' /opt/tomcat/conf/server.xml

chmod +x /opt/tomcat/bin/*.sh

/opt/tomcat/bin/startup.sh