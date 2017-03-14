#!/bin/bash

#	Author:zhang
#	Date:2016.12.22
#	Name:	nginx安装脚本
#	
#	需要安装pcre 库，zlib库，openssl库

Dir_Install=/usr/local
Nginx_Url=http://nginx.org/download/nginx-1.10.3.tar.gz
Pcre_Url=https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz
Zlib_Url=https://nchc.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz

#安装包默认下载于/opt/src
[ -d /opt/src ] || {mkdir /opt/src;}
[ -d /usr/local/nginx] || {mkdir /usr/local/nginx;}

function get_prg(){
	cd /opt/src
	wget $Nginx_Url
	Prg_nginx_name=`echo $Nginx_Url | cut -d '/' -f 5`
	tar -zxvf $Prg_nginx_name
	Nginx_Dir=`echo $Prg_nginx_name | cut -d '.' -p 1-3`	

	wget $Pcre_Url
	Prg_pcre_name=`echo $Pcre_Url | cut -d '/' -f 6`
	tar -zxvf $Prg_pcre_name
	Pcre_Dir=`echo $Prg_pcre_name | cut -d '.' -f 1-2`

	wget $Zlib_Url
	Prg_zlib_name=`echo $Zlib_Url | cut -d '/' -f 8`
	tar -zxvf $Prg_zlib_name
	Zlib_Dir=`echo $Prg_zlib_name | cut -d '.' -f 1-3`
}


#下载软件包到/opt/src目录
function nginx_install{
	cd /opt/src
	wget $Nginx_Url
	Prg_name=`echo $Nginx_Url | cut -d '/' -f 5`
	tar -zxvf $Prg_name
	./configure --prefix=/usr/local/nginx \
			--with-pcre=/usr/local/pcre \   #pcre只需要将源码包解压即可，其他的将会由nginx自动完成
			--with-zlib=/usr/local/zlib \	#同上
			--with-http_ssl_module \	#需要openssl library
			--with-stream \
	&& make && make install
}


get_prg
nginx_install
