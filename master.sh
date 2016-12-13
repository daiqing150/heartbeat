#!/bin/bash
#change hostname
hostname data-1-1
sed -i '2c HOSTNAME=data-1-1' /etc/sysconfig/network

#config hots file
cp /etc/hosts /etc/hosts_bak_$(date +%F)
cat >>/etc/hosts<<eof
10.0.0.221  data-1-1
10.0.0.222  data-1-2 
eof

#add static route
route add -host 10.0.0.222 dev eth1
echo '/sbin/route  add -host 10.0.0.222 dev eth1' >>/etc/rc.local 

#install epel
rpm -ivh epel-release-6-8.noarch.rpm

#install heartbeat service
yum install heartbeat* -y

#put heartbeat configuetion file
cat >>/etc/ha.d/ha.cf<<eof
debugfile /var/log/ha-debug
logfile /var/log/ha-log
logfacility local1

keepalive 2
deadtime 30
warntime 10
initdead 60

mcast eth1 225.0.0.221 694 1 0

auto_failback on
node data-1-1
node data-1-2
crm no
eof

cat >>/etc/ha.d/authkeys<<eof
auth 1
1 sha1 eb800fde8afdfe5dd9bfcf0380d94e20
eof

chmod 600 /etc/ha.d/authkeys

cat >>/etc/ha.d/haresources<<eof
data-1-1 IPaddr::10.128.231.248/24/eth0 httpd
eof

echo '######HeartBeat service has been finished install#######'

#start apache install
yum install httpd -y

echo '10.128.231.221' >>/var/www/html/index.html

/etc/init.d/heartbeat start
