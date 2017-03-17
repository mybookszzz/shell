#!/bin/bash
#
#author:zhang
#date:2017-03-17
#system:centos6.8 minimal

#mysql_server依赖包
yum install numactl

echo "使用rpm包安装mysql"
echo "请上传mysql bundle包"

[ -d /opt/src ]||{ mkdir /opt/src; }
cd /opt/src
Mysql_src=/opt/src/mysql$RANDOM
echo mysql文件上传目录:$Mysql_src
mkdir $Mysql_src
cd $Mysql_src
rz -bey
tar -xvf mysql*.rpm-bundle.tar

#删除系统自带mysql_lib
rpm -e mysql-libs-5.1.73-7.el6.x86_64 --nodeps
rpm -ivh mysql-community-common-*.rpm
rpm -vih mysql-community-libs-*.rpm
rpm -vih mysql-community-client-*.rpm
rpm -vih mysql-community-server-*.rpm


#my.cnf设置
cp /etc/my.cnf /etc/my.cnf.init
cat >> /etc/my.cnf <<'EOF'
innodb_rollback_on_timeout=1
innodb_lock_wait_timeout=600
max_connections=350
log-bin=mysql-bin
binlog-format = 'ROW'
EOF
