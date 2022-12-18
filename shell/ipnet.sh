#!/bin/bash
cd /
echo 1 > /proc/sys/net/ipv4/ip_forward
ifconfig eth1 192.168.1.20 netmask 255.255.255.0

iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#onvif端口
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to-destination 192.168.1.88:80
iptables -t nat -A POSTROUTING -d 192.168.1.88 -p tcp --dport 80 -j SNAT --to 192.168.1.20
#WEB端口
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 82 -j DNAT --to-destination 192.168.1.88:81
iptables -t nat -A POSTROUTING -d 192.168.1.88 -p tcp --dport 81 -j SNAT --to 192.168.1.20
#RTSP端口
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 554 -j DNAT --to-destination 192.168.1.88:554
iptables -t nat -A POSTROUTING -d 192.168.1.88 -p tcp --dport 554 -j SNAT --to 192.168.1.20
#页面取流端口
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 5000 -j DNAT --to-destination 192.168.1.88:5000
iptables -t nat -A POSTROUTING -d 192.168.1.88 -p tcp --dport 5000 -j SNAT --to 192.168.1.20
#HTTP端口
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8011 -j DNAT --to-destination 192.168.1.88:8011
iptables -t nat -A POSTROUTING -d 192.168.1.88 -p tcp --dport 8011 -j SNAT --to 192.168.1.20ubuntu@VM-4-5-ubuntu:~$ 