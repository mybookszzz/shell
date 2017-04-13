#!/usr/bin/bash

# install some pkg
yum install vim epel-release man lrzsz nc
yum install gcc gcc-c++ perl

#set hostname
hostname `ifconfig eth0|grep "inet addr"|awk '{print $2}'|cut -d ":" -f 2`

#stop selinux
sed -i 's/SELINUX=enfor.*/SELINUX=permissive/' /etc/sysconfig/selinux

#chkconfig
chkconfig postfix off
chkconfig sendmail off

#del user and group
userdel games
groupdel games

#stop ctrl+alt+del to reboot
sed -i '/^exec/ s/exec/#exec/' /etc/init/control-alt-delete.conf
