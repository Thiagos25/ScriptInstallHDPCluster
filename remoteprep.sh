#!/bin/bash -x
#
#scp -i /Users/tsantiago/Desktop/field.pem /Users/tsantiago/Desktop/scriptsFolder/* centos@bacen-1:/home/centos/

#Execute it on node1 = Ambari node
# /home/centos/remoteprep.sh

#HOSTPOSTFIX=.field.hortonworks.com
USER=centos
NUMINSTANCES=8
HOSTPREFIX='bacen-'
LOCALPEM=~/.ssh/field.pem

#Ambari REPO
AMBARI_REPO='http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.5.2.0/ambari.repo'

#HDF Management Pack	
HDF_PACK_URL='http://public-repo-1.hortonworks.com/HDF/centos6/3.x/updates/3.0.0.0/tars/hdf_ambari_mp/'
HDF_PACK='hdf-ambari-mpack-3.0.0.0-453.tar.gz'

n=1
while [[ $n -le $NUMINSTANCES ]]; do
    echo '=-----------------------------------> Start preparation node: '$hostprefix$n

    sudo scp -i $LOCALPEM $LOCALPEM $USER@$HOSTPREFIX$n:/home/centos/.ssh/id_rsa
    sudo ssh -t -i $LOCALPEM $USER@$HOSTPREFIX$n 'sudo -n cp /home/centos/.ssh/authorized_keys /root/.ssh/'
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "echo never > /sys/kernel/mm/transparent_hugepage/enabled; echo never > /sys/kernel/mm/transparent_hugepage/defrag"

    sudo scp -i $LOCALPEM /home/$USER/centos_selinux_config root@$HOSTPREFIX$n:/etc/selinux/config
    sudo scp -i $LOCALPEM /home/$USER/centos_etc_profile root@$HOSTPREFIX$n:/etc/profile
    sudo scp -i $LOCALPEM /home/$USER/centos_rc_local root@$HOSTPREFIX$n:/etc/rc.d/rc.local
    
    #Install pre requirements
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "/usr/bin/chmod +x /etc/rc.d/rc.local; yum install -y net-tools vim reposync curl wget unzip zip chkconfig tar openssh-clients ntp; systemctl enable ntpd; systemctl start ntpd; systemctl disable firewalld; service firewalld stop; setenforce 0"

    #Install Java 8
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo wget -P /opt/ --no-cookies --no-check-certificate --header 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie' 'http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz'"
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo tar xzf /opt/jdk-8u141-linux-x64.tar.gz -C /opt/"

    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo alternatives --install /usr/bin/java java /opt/jdk1.8.0_141/bin/java 4"
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_141/bin/jar 2"
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_141/bin/javac 2"
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo alternatives --set jar /opt/jdk1.8.0_141/bin/jar"
    sudo ssh -t -i $LOCALPEM root@$HOSTPREFIX$n "sudo alternatives --set javac /opt/jdk1.8.0_141/bin/javac"

    # Setup JAVA_HOME Variable
    sudo ssh -t root@$HOSTPREFIX$n "export JAVA_HOME=/opt/jdk1.8.0_141"
    # Setup JRE_HOME Variable
    sudo ssh -t root@$HOSTPREFIX$n "export JRE_HOME=/opt/jdk1.8.0_141/jre"
    # Setup PATH Variable
    sudo ssh -t root@$HOSTPREFIX$n "export PATH=$PATH:/opt/jdk1.8.0_141/bin:/opt/jdk1.8.0_141/jre/bin"

    let n++
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
       
    fi
        
    sleep 5
    sudo ssh -t root@$HOSTPREFIX$n "sleep 5; /sbin/reboot"
done
