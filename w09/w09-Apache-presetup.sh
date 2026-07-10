#!/bin/bash
#Script Name: w10 - Apache.sh
#Script Purpose: to Install, Configure, and validate DNS, firewall, and Apache settings
#Date Created: 09/07/2026 @ 20:51
#Version: 1.0.0
#Author(s): Kaylee Froats


#---FIREWALL SETUP---#
##Subscript Name: firewall setup
##Subscript Purpose: allows ip traffic to/from port(s) _____
##Date Created: 09/07/2026 @ 20:51
##Version: 1.0.0

#stops firewalld so iptables doesn't conflict with it
systemctl stop firewalld
systemctl disable firewalld

#stops SELINUX from conflicting with iptables
grep -v 'SELINUX=enforcing' /etc/selinux/config > ./temp_file.txt
grep -v 'SELINUX=disabled' ./temp_file.txt > /etc/selinux/config
echo "SELINUX=disabled" >> /etc/selinux/config

iptables -F

#allowing traffic on CLIENT network
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 443 -j ACCEPT

#disallowing traffic on SERVER network
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 80 -j REJECT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 443 -j REJECT

#allowing only secure traffic on ALIAS network
iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 80 -j REJECT


iptables -L


#---DNS (Minor) SETUP---#
##Subscript Name: DNS_setup
##Subscript Purpose: builds and configures server as DNS master for example50.lab domain
##Date Created: 25/06/2026 @ 01:24
##Version: 1.0.1


#Install DNS Utilities
dnf install bind bind-utils -y

#Configure DNS
sed -i 's/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { 127.0.0.1; 172.16.30.50; };/g' /etc/named.conf
sed -i 's/allow-query     { localhost; };/allow-query     { localhost; 172.16.0.0\/16; };/g' /etc/named.conf
grep -v 'nameserver' /etc/resolv.conf > ./temp_file.txt
cat ./temp_file.txt > /etc/resolv.conf
echo 'nameserver 172.16.30.50' >> /etc/resolv.conf

#Creating FWD Lookup Zones
touch /etc/named/fwd.example50.lab
touch /etc/named/fwd.site50.lab

cat > /etc/named/fwd.example50.lab <<EOF
;FWD Lookup Zone for froa0019-SRV.example50.lab
;serial number uses format of revision number + creation date
\$TTL 86400 ;24 hours
@ IN SOA ns1.example50.lab. root.example50.lab. (
	005120626 ; Serial breakdown: revision (3), day (2), month (2), year (2).
	28800 ; Refresh (8h)
	14400 ; Retry (4h)
	604800 ; Expiry (1w)
	10800 ; Minimum TTL (3h)
)
; Name Server
	IN NS ns1.example50.lab.
	IN NS ns2.example50.lab.
; A Record Definitions
ns1 IN A 172.16.30.50
ns2 IN A 172.16.31.50
ftp IN A 172.16.32.50
www IN A 172.16.30.50
secure IN A 172.16.32.50

EOF

cat > /etc/named/fwd.site50.lab <<EOF
;serial number uses format of revision number + creation date
\$TTL 86400

@ IN SOA site50.lab root.site50.lab. (
	002090726 ; Serial
	28800 ; Refresh (8h)
	14400 ; Retry (4h)
	604800 ; Expiry (1w)
	10800 ; Minimum TTL (3h)
)
	IN NS ns1.site50.lab.

ns1 IN A 172.16.30.50
www IN A 172.16.30.50

EOF

#add FWD Lookup Zones to named.conf
cat <<EOF >> /etc/named.conf
zone "example50.lab" IN {
        type master;
        file "/etc/named/fwd.example50.lab";
};
EOF
cat <<EOF >> /etc/named.conf
zone "site50.lab" IN {
        type master;
        file "/etc/named/fwd.site50.lab";
		allow-transfer { 172.16.31.50; };
};
EOF

systemctl restart named.service





echo "waiting for services to load"
sleep 20
#---VERIFICATION---#
iptables -L --line-numbers
dig ns1.example50.lab
cat /etc/named.conf
