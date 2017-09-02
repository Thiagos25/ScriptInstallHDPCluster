#!/bin/bash -x
#
USER=root
NUMINSTANCES=8
HOSTPREFIX='hdp'
LOCALPEM='~/.ssh/id_rsa'

hdp-node7.cpoc.local

#Ambari REPO
AMBARI_REPO='http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.5.1.0/ambari.repo'


n=0
while [[ $n -le $NUMINSTANCES ]]; do
    echo '=-----------------------------------> Start preparation node: '$hostprefix$n
        
    # Desabilitar IPV6
	sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf'
	
	# Instalar Pré-requisitos
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n "/usr/bin/chmod +x /etc/rc.d/rc.local; yum install -y net-tools vim reposync curl wget unzip zip chkconfig tar openssh-clients ntp ntpdate ntp-doc; chkconfig ntpd on; chkconfig iptables off; /etc/init.d/iptables stop; service ntpd start; systemctl disable firewalld; service firewalld stop; setenforce 0"

	# Desabilitar HugePages
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n "echo never > /sys/kernel/mm/transparent_hugepage/enabled; echo never > /sys/kernel/mm/transparent_hugepage/defrag"

    # Desabilitar IPV6
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf'

    ## FIREWALL
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'systemctl disable firewalld'
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n '/bin/systemctl stop  firewalld.service'
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'cp -n /etc/selinux/config /etc/selinux/config~'
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n "cat /etc/selinux/config~ | sed -e 's/SELINUX=enforcing/SELINUX=disabled/g' > /etc/selinux/config"
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'echo "enabled=0" >> /etc/yum/pluginconf.d/refresh-packagekit.conf'

    # Umask
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'umask 0022'
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'echo umask 0022 >> /etc/profile'
done

#Restart from last to firt one
while [[ $n -gt 1  ]]; do

    let n--
    if [[ $n == 1 ]];
    then
       #Ambari REPO
       sudo wget -nv $AMBARI_REPO -O /etc/yum.repos.d/ambari.repo

       echo '=-----------------------------------> Start Ambari install'
       sudo yum install ambari-server
       echo '=-----------------------------------> Start Ambari Setup'
       sudo ambari-server setup
       
       echo '=-----------------------------------> Start HDF Management Pack Install'
       sudo wget -P /tmp/ "$HDF_PACK_URL$HDF_PACK"
       sudo ambari-server install-mpack --mpack=/tmp/$HDF_PACK --verbose
       
       sudo yum install mysql-connector-java*
       sudo ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar

    fi
        
    sleep 5
    sudo ssh -t root@$HOSTPREFIX$n "sleep 5; /sbin/reboot"
done







