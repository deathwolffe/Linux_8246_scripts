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

cat > /etc/openldap/ldifs/base.ldif <<EOF
dn: dc=example50,dc=lab
dc: example50
objectClass: top
objectClass: domain
EOF

cat > /etc/openldap/ldifs/ou.ldif <<EOF
#users OU
dn: ou=accounts,dc=example50,dc=lab
ou: accounts
objectClass: top
objectClass: organizationalUnit

#groups OU
dn: ou=groups,dc=example50,dc=lab
ou: groups
objectClass: top
objectClass: organizationalUnit

EOF
cat > /etc/openldap/ldifs/ou.ldif <<EOF
#users linuxuser1
dn: uid=linuxuser1,ou=accounts,dc=example50,dc=lab
objectClass: inetOrgPerson
objectClass: posixAccount
cn: user 1
sn: user 1
uid: linuxuser1
uidNumber: 1001
gidNumber: 1000
homeDirectory: /home/linuxuser1
loginShell: /bin/bash
mail: linuxuser1@example50.lab
userPassword:

#users linuxuser2
dn: uid=linuxuser2,ou=accounts,dc=example50,dc=lab
objectClass: inetOrgPerson
objectClass: posixAccount
cn: user 2
sn: user 2
uid: linuxuser2
uidNumber: 1002
gidNumber: 1000
homeDirectory: /home/linuxuser2
loginShell: /bin/bash
mail: linuxuser2@example50.lab
userPassword:

#users linuxuser3
dn: uid=linuxuser3,ou=accounts,dc=example50,dc=lab
objectClass: inetOrgPerson
objectClass: posixAccount
cn: user 3
sn: user 3
uid: linuxuser3
uidNumber: 1003
gidNumber: 1000
homeDirectory: /home/linuxuser3
loginShell: /bin/bash
mail: linuxuser3@example50.lab
userPassword:

#group users
dn: cn=users,ou=groups,dc=example50,dc=lab
objectClass: posixGroup
#group name
cn: users
#Linux GID
gidNumber: 1000
memberUid: linuxuser1
memberUid: linuxuser2
memberUid: linuxuser3
EOF

ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f base.ldif
ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f leaf.ldif

systemctl restart slapd

touch /etc/openldap/ldifs/hostsou.ldif
touch /etc/openldap/ldifs/hostsleaf.ldif

cat > /etc/openldap/ldifs/hostsou.ldif <<EOF
#hosts OU
dn: ou=hosts,dc=example50,dc=lab
ou: hosts
objectClass: top
objectClass: organizationalUnit
EOF

cat > /etc/openldap/ldifs/hostsleaf.ldif <<EOF
#host happy
dn: cn=happy.example50.lab,ou=hosts,dc=example50,dc=lab
objectClass: device
objectClass: ipHost
cn: happy.example50.lab
ipHostNumber: 172.16.32.167

#host peachy
dn: cn=peachy.example50.lab,ou=hosts,dc=example50,dc=lab
objectClass: device
objectClass: ipHost
cn: peachy.example50.lab
ipHostNumber: 172.16.33.167

EOF


ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f hostsou.ldif
ldapadd -x -D "cn=ldapadm,dc=example50,dc=lab" -w secret -f hostsleaf.ldif

systemctl restart slapd
enable nslcd
