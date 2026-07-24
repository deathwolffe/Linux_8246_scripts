#!/bin/bash
#Script Name: w11-LDAP-setup.sh
#Script Purpose: to Install, Configure, and validate LDAP settings
#Date Created: 23/07/2026 @ 22:51
#Version: 1.0.0
#Author(s): Kaylee Froats

yum -y install openldap*
mkdir /var/lib/ldap/example50.lab/
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/example50.lab/
mv /var/lib/ldap/example50.lab/DB_CONFIG.example /var/lib/ldap/example50.lab/DB_CONFIG
chown ldap:ldap /var/lib/ldap/example50.lab/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*

mv /etc/openldap/slapd.d /etc/openldap/slapd.d.backup
touch /etc/openldap/slapd.conf
