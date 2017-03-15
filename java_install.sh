#!/bin/bash

#author:zhang
#date:2017-03-15

Java_src_dir=/opt/src/java$RANDOM

which java || { echo "java is not install"; }

mkdir $Java_src_dir
cd $Java_src_dir
echo "please upload jdk.tar.gz..."
rz -bey
tar -zxvf jdk*.tar.gz
Java_Name=`ls -l | grep ^d | awk '{print $9}'`
cp -rf $Java_Name /usr/local/jdk

cat >>/etc/profile<<"EOF"


#Java set
JAVA_HOME=/usr/local/jdk
CLASSPATH=$JAVA_HOME/lib/
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH
EOF

source /etc/profile
