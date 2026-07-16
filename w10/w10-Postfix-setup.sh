#!/bin/bash
#Script Name: w10-Postfix-setup.sh
#Script Purpose: to Install, Configure, and validate Postfix settings
#Date Created: 15/07/2026 @ 16:25
#Version: 1.0.0
#Author(s): Kaylee Froats

#install Postfix
dnf install postfix mailx -y
systemctl start postfix
systemctl enable postfix

#configuring Postfix
sed -i 's/#myhostname = host.domain.tld/myhostname = mail.example50.lab/g' /etc/postfix/main.cf
sed -i 's/#mydomain = domain.tld/mydomain = example50.lab/g' /etc/postfix/main.cf
sed -i 's/#myorigin = $mydomain/myorigin = $mydomain/g' /etc/postfix/main.cf
sed -i 's/inet_interfaces = localhost/inet_interfaces = localhost, 172.16.30.167/g' /etc/postfix/main.cf
sed -i 's/mydestination = $myhostname, localhost.$mydomain, localhost/#mydestination = $myhostname, localhost.$mydomain, localhost/g' /etc/postfix/main.cf
sed -i 's/##mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/g' /etc/postfix/main.cf
sed -i 's/#mynetworks = 168.100.189.0/28, 127.0.0.0/8/mynetworks = 172.16.30.0/28, 127.0.0.0/8/g' /etc/postfix/main.cf
echo 'masquerade_domain = example50.lab' > /etc/postfix/main.cf
sed -i 's/#home_mailbox = Maildir\//home_mailbox = Maildir\//g' /etc/postfix/main.cf

systemctl restart postfix
systemctl enable postfix
