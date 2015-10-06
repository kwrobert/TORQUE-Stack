#####################################################################################################
# Script: headnode_config.sh
# Author: Kyle Robertson
# Date: September 18, 2015
# Company: Worlcom Exchange Inc.
# Description: A cloud init file for installing TORQUE and all its dependencies on compute nodes
#####################################################################################################

#!/bin/bash

echo "root:stackops" | chpasswd
echo "centos:stackops" | chpasswd
yum update
yum install libtool openss-devel libxml2-devel boost-devel gcc gcc-c++ git nmap 
IP="$(ifconfig eth0 | grep "inet" | awk '{print $2;}' | head -1)"
HOSTNAME="$(hostname)"
echo "$IP $HOSTNAME" >> /etc/hosts
git clone https://github.com/adaptivecomputing/torque.git -b 5.1.1 torque_5.1.1
cd torque_5.1.1
./autogen.sh
./configure
make
make install
cp contrib/init.d/trqauthd /etc/init.d/
chkconfig --add trqauthd
echo /usr/local/lib > /etc/ld.so.conf.d/torque.conf
ldconfig
service trqauthd start
echo $(hostname) >> /var/spool/torque/server_name
export PATH=/usr/local/bin/:/usr/local/sbin/:$PATH
./torque.setup root
cp contrib/init.d/pbs_server /etc/init.d
chkconfig --add pbs_server
service pbs_server restart