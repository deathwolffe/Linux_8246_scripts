#!/bin/bash
#Script Name: w11-LDAP-setup.sh
#Script Purpose: to Install, Configure, and validate LDAP settings
#Date Created: 23/07/2026 @ 22:51
#Version: 1.0.0
#Author(s): Kaylee Froats

yum -y install openldap*
mkdir -p /var/lib/ldap/example50.lab/
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/example50.lab/
mv /var/lib/ldap/example50.lab/DB_CONFIG.example /var/lib/ldap/example50.lab/DB_CONFIG
chown ldap:ldap /var/lib/ldap/example50.lab/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*

mv /etc/openldap/slapd.d /etc/openldap/slapd.d.backup
touch /etc/openldap/slapd.conf

slaptest -u
systemctl start slapd
systemctl enable slapd
systemctl status slapd | grep "active"

ldapsearch -x

cat > /etc/openldap/slapd.conf <<EOF
include /etc/openldap/schema/core.schema
include /etc/openldap/schema/cosine.schema
include /etc/openldap/schema/inetorgperson.schema
include /etc/openldap/schema/nis.schema

pidfile /var/run/openldap/slapd.pid

loglevel 256

database bdb

suffix "dc=example50,dc=lab"

directory /var/lib/ldap/example50.lab

rootdn "cn=ldapadm,dc=example50,dc=lab"

rootpw secret

EOF

systemctl restart slapd
systemctl status slapd
ldapsearch -x

mkdir -p /etc/openldap/ldifs/
touch /etc/openldap/ldifs/base.ldif
touch /etc/openldap/ldifs/ou.ldif
touch /etc/openldap/ldifs/leaf.ldif

ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f base.ldif
ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f leaf.ldif

ldapsearch -x
