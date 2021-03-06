#!/bin/bash

# 請先輸入您的相關參數，不要輸入錯誤了！
  EXTIF="eth0"             # 這個是可以連上 Public IP 的網路介面
  INIF="eth0"              # 內部 LAN 的連接介面；若無則寫成 INIF=""
  INNET="10.0.100.0/24" # 若無內部網域介面，請填寫成 INNET=""
  #INNET="10.0.100.0/20" # 若無內部網域介面，請填寫成 INNET=""
  export EXTIF INIF INNET

# 第一部份，針對本機的防火牆設定！##########################################
# 1. 先設定好核心的網路功能：
  echo "1" > /proc/sys/net/ipv4/tcp_syncookies
  echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
  for i in /proc/sys/net/ipv4/conf/*/{rp_filter,log_martians}; do
        echo "1" > $i
  done
  for i in /proc/sys/net/ipv4/conf/*/{accept_source_route,accept_redirects,\
send_redirects}; do
        echo "0" > $i
  done

# 2. 清除規則、設定預設政策及開放 lo 與相關的設定值
  PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin; export PATH
  iptables -F
  iptables -X
  iptables -Z
  iptables -P INPUT   DROP
  iptables -P OUTPUT  ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# 3. 啟動額外的防火牆 script 模組
  if [ -f /usr/local/virus/iptables/iptables.deny ]; then
        sh /usr/local/virus/iptables/iptables.deny
  fi
  if [ -f /usr/local/virus/iptables/iptables.allow ]; then
        sh /usr/local/virus/iptables/iptables.allow
  fi
  if [ -f /usr/local/virus/httpd-err/iptables.http ]; then
        sh /usr/local/virus/httpd-err/iptables.http
  fi

# 4. 允許某些類型的 ICMP 封包進入
  AICMP="0 3 3/4 4 11 12 14 16 18"
  for tyicmp in $AICMP
  do
    iptables -A INPUT -i $EXTIF -p icmp --icmp-type $tyicmp -j ACCEPT
  done

# 5. 允許某些服務的進入，請依照你自己的環境開啟
# iptables -A INPUT -p TCP -i $EXTIF --dport  21 --sport 1024:65534 -j ACCEPT # FTP
iptables -A INPUT -p TCP -i $EXTIF --dport  22 --sport 1024:65534 -j ACCEPT # SSH
iptables -A INPUT -p TCP -i $EXTIF --dport  11631 --sport 1024:65534 -j ACCEPT # SSH
# iptables -A INPUT -p TCP -i $EXTIF --dport  25 --sport 1024:65534 -j ACCEPT # SMTP
# iptables -A INPUT -p UDP -i $EXTIF --dport  53 --sport 1024:65534 -j ACCEPT # DNS
# iptables -A INPUT -p TCP -i $EXTIF --dport  53 --sport 1024:65534 -j ACCEPT # DNS
iptables -A INPUT -p TCP -i $EXTIF --dport  80 --sport 1024:65534 -j ACCEPT # WWW
# iptables -A INPUT -p TCP -i $EXTIF --dport 110 --sport 1024:65534 -j ACCEPT # POP3
iptables -A INPUT -p TCP -i $EXTIF --dport 443 --sport 1024:65534 -j ACCEPT # HTTPS
iptables -A INPUT -p TCP -i $EXTIF --dport  14689 --sport 1024:65534 -j ACCEPT # RSYNC


# 第二部份，針對後端主機的防火牆設定！###############################
# 1. 先載入一些有用的模組
  modules="ip_tables iptable_nat ip_nat_ftp ip_nat_irc ip_conntrack 
ip_conntrack_ftp ip_conntrack_irc"
  for mod in $modules
  do
      testmod=`lsmod | grep "^${mod} " | awk '{print $1}'`
      if [ "$testmod" == "" ]; then
            modprobe $mod
      fi
  done

# 2. 清除 NAT table 的規則吧！
  iptables -F -t nat
  iptables -X -t nat
  iptables -Z -t nat
  iptables -t nat -P PREROUTING  ACCEPT
  iptables -t nat -P POSTROUTING ACCEPT
  iptables -t nat -P OUTPUT      ACCEPT

# 3. 若有內部介面的存在 (雙網卡) 開放成為路由器，且為 IP 分享器！
  if [ "$INIF" != "" ]; then
    iptables -A INPUT -i $INIF -j ACCEPT
    echo "1" > /proc/sys/net/ipv4/ip_forward
    if [ "$INNET" != "" ]; then
        for innet in $INNET
        do
            iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE
        done
    fi
  fi
  # 如果你的 MSN 一直無法連線，或者是某些網站 OK 某些網站不 OK，
  # 可能是 MTU 的問題，那你可以將底下這一行給他取消註解來啟動 MTU 限制範圍
  # iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss \
  #          --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu

# 4. NAT 伺服器後端的 LAN 內對外之伺服器設定
# iptables -t nat -A PREROUTING -p tcp -i $EXTIF --dport 80 \
#          -j DNAT --to-destination 192.168.1.210:80 # WWW

# 5. 特殊的功能，包括 Windows 遠端桌面所產生的規則，假設桌面主機為 1.2.3.4
# iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4  --dport 6000 \
#          -j DNAT --to-destination 192.168.100.10
# iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4  --sport 3389 \
#          -j DNAT --to-destination 192.168.100.20

# 6. 最終將這些功能儲存下來吧！
/etc/init.d/iptables save



