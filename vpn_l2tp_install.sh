#!/bin/bash

function true_or_fault(){
read -p "请输入:" flag1
if [ $flag1 == "Yes" ];then
	continue
elif [ $flag1 == "No" ];then
	break
else 
	read -p "输入不正确，请重新输入:" flag1
fi
}

echo "yum安装xl2tpd..."
yum -y install xl2tpd
echo "xl2tpd版本"
xl2tpd -v
echo "修改配置文件"
L2TP_CONF=`rpm -ql xl2tpd|grep conf$`
echo "$L2TP_CONF"
echo "是否启用IPsec追踪?(Yes/No)"
while true
do
read -p "请输入:" flag1
if [ $flag1 == "Yes" ];then
        continue
elif [ $flag1 == "No" ];then
        break
else
        read -p "输入不正确，请重新输入:" flag1
fi
done
echo "请输入监听地址:(默认监听0.0.0.0)"
read xl2tp_listen_address
echo "请输入监听端口:(默认监听1701)"
read xl2tp_listen_port


yum install ppp -y
if [ -z /etc/ppp/options.xl2tpd ];then
touch /etc/ppp/options.xl2tpd
else 
pass
fi
cat >/etc/ppp/options.xl2tpd<EOF
#vpn使用的dns服务器
ms-dns 8.8.8.8
ms-dns 8.8.4.4
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
EOF


#添加xl2tpd用户
vim /etc/ppp/chap-secrets

#开启内核转发
ifnat=`sysctl -p|grep ip_forward|cut -d ' ' -f 3`
if [ $ifnat -eq 0 ];then
	echo "内核转发没有开启"
	echo "即将开启"
	echo 1 > /proc/sys/net/ipv4/ip_forward
else
	echo "内核转发已经开启"
#设置防火墙规则
iptables -t nat -A POSTROUTING -m policy --dir out --pol none -j MASQUERADE
iptables -A INPUT -p udp -m multiport --destination-ports  500,1701,4500 -j ACCEPT 


yum install openswan -y
touch /etc/ipsec.d/v4-hole.conf
cat > /etc/ipsec.d/v4-hole.conf < EOF
config setup
    protostack=netkey
    dumpdir=/var/run/pluto/
    nat_traversal=yes
    virtual_private=%v4:VPN客户端内网地址网段/24

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=公网地址
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF
touch /etc/ipsec.d/share-psk.secrets
cat > /etc/ipsec.d/share-psk.secrets < EOF
%any:PSK "miyao"
EOF


#修改内核参数
cat > /etc/sysctl.conf < EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
EOF
sysctl -p
