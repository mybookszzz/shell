#!/bin/bash

#author:zhang
#date:2017-03-08

#upgrade python to 2.7.*

#检查现有系统python版本
echo "当前系统python版本:"
python --version

#升级python
Pynew_Url=https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
Pynew_Version=`echo $Pynew_Url|cut -d '/' -f 6`
echo "升级到新版本$Pynew_Version"

#read -p "确定要继续么?(Yes/No)" ifcontinue
#while [ $ifcontinue=="Yes" || $ifcontinue=="No" ]
#do
#if [ $ifcontinue=="Yes" ];then
#	echo "continue..."
#elif [ $ifcontinue=="No" ];then
#	echo "stop...exit..."
#	exit 1
#else
#	read -p "确定要继续么?(Yes/No)" ifcontinue
#fi
#done


mkdir /tmp/python_update27
cd /tmp/python_update27
wget $Pynew_Url
tar -zxvf Python-2.7.13.tgz
cd Python-2.7.13

if [ ! -d /usr/local/python27 ];then
mkdir /usr/local/python27
fi

./configure --prefix=/usr/local/python27
make && make install
echo "新版本号"
/usr/local/python27/bin/python2.7 -V
echo "旧版本号"
/usr/bin/python -V
cp /usr/bin/python /usr/bin/python2.6.6
ln -s -f /usr/local/python27/bin/python2.7 /usr/bin/python

echo "修改yum文件/usr/bin/yum"
sed -i "s@#!/usr/bin/python@#!/usr/bin/python2.6.6@" /usr/bin/yum
