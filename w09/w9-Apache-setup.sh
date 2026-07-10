#!/bin/bash
#---HTTP SETUP---#
##Subscript Name: HTTP setup
##Subscript Purpose: 
##Date Created: 09/07/2026 @ 21:28
##Version: 1.0.1

#installs httpd utilities and starts inital setup of base config
dnf install httpd -y
systemctl start httpd.service
systemctl enable httpd.service

#updates apache config
cat > /etc/httpd/conf/httpd.conf <<EOF
ServerName froa0019-srv.example50.lab:80
ServerRoot "/etc/httpd"
ServerAdmin root@example50.lab
DocumentRoot /var/www/html
ErrorLog logs/error_log
LogLevel info

LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule systemd_module modules/mod_systemd.so
LoadModule log_config_module modules/mod_log_config.so
#Transfer log logs/access_log
LoadModule mime_module modules/mod_mime.so
#TypesConfig /etc/mime.types
LoadModule authz_core_module modules/mod_authz_core.so
#LoadModule dir_module modules/mod_dir.so
#LoadModule ssl_module modules/mod_ssl.so

User apache
Group apache

Listen 80
Listen 443

<VirtualHost 172.16.30.50:80>
	ServerName www.example50.lab
	DocumentRoot /var/www/vhosts/www.example50.lab/html/
	ErrorLog /var/www/vhosts/www.example50.lab/log/error.log
</VirtualHost>

<VirtualHost 172.16.30.50:80>
	ServerName www.site50.lab
	DocumentRoot /var/www/vhosts/www.site50.lab/html/
	ErrorLog /var/www/vhosts/www.site50.lab/log/error.log
</VirtualHost>

<VirtualHost 172.16.32.50:443>
	ServerName secure.example50.lab
	DocumentRoot /var/www/vhosts/secure.example50.lab/html/
	SSLCertificateFile /etc/httpd/tls/cert/example50.cert
	SSLCertificateKeyFile /etc/httpd/tls/key/example50.key
	SSLEngine On
</VirtualHost>

EOF

systemctl restart httpd.service

#creates the site files
mkdir -p /var/www/vhosts/www.example50.lab/html
mkdir /var/www/vhosts/www.example50.lab/log

mkdir -p /var/www/vhosts/www.site50.lab/html
mkdir /var/www/vhosts/www.site50.lab/log

mkdir -p /var/www/vhosts/secure.example50.lab/html
mkdir /var/www/vhosts/secure.example50.lab/log

mkdir -p /etc/httpd/tls/key
mkdir /etc/httpd/tls/cert
chmod 700 /etc/httpd/tls/key
chmod 755 /etc/httpd/tls/cert

openssl req -x509 -newkey rsa -days 120 -nodes -keyout /etc/httpd/tls/key/example50.key -out /etc/httpd/tls/cert/example50.cert
chmod 600 /etc/httpd/tls/key/example50.key
chmod 644 /etc/httpd/tls/cert/example50.cert

cat > /var/www/vhosts/www.example50.lab/html/index.html <<EOF
<head><Title>www.example50.lab</Title></head>
<H1>Host:www.example50.lab [172.16.30.50:80]</H1>
EOF

cat > /var/www/vhosts/www.site50.lab/html/index.html <<EOF
<head><Title>www.site50.lab</Title></head>
<H1>Host:www.site50.lab [172.16.30.50:80]</H1>
EOF

cat > /var/www/vhosts/www.example50.lab/html/index.html <<EOF
<head><Title>secure.example50.lab</Title></head>
<H1>Host:secure.example50.lab [172.16.32.50:443]</H1>
EOF

