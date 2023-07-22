#!/bin/bash

## From here Run all the command on all the nodes 

#Create user on all nodes 
useradd -d /home/cephuser -m cephuser 

## Set passwod for cephuser 
echo "passwd" | passwd --stdin cephuser

## Make cephuser sudo password less 

echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
chmod 0440 /etc/sudoers.d/cephuser
sed -i s'/Defaults requiretty/#Defaults requiretty'/g /etc/sudoers

## modify yum repository 
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
yum install epel-release -y 

## Disable selinux config 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 

## Add hosts entries 
echo '192.168.198.139 ceph1' | sudo tee -a /etc/hosts
echo '192.168.198.143 ceph2' | sudo tee -a /etc/hosts
echo '192.168.198.146 ceph3' | sudo tee -a /etc/hosts

## Disable the firewalld 
sudo systemctl disable --now firewalld 

## From here all the command on all the nodes ends.

## Switch user  command should be run on the provisinoer nodes 

su - cephuser
ssh-keygen
sudo yum install http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/sshpass-1.09-4.el8.x86_64.rpm -y
ssh-copy-id cephuser@ceph1
ssh-copy-id cephuser@ceph2
ssh-copy-id cephuser@ceph3



sudo dnf -y install dnf-plugins-core
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf config-manager --set-enabled powertools

sudo dnf install git -y
sudo git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible/
sudo git checkout stable-5.0
sudo git branch
sudo yum install python3-pip -y 
sudo pip3 install -r requirements.txt      ##if errors occurs then 
sudo pip3 install -U pip

## Ansible Version 
ansible --version 
#############################################################################################
ansible 2.9.27
  config file = /home/cephuser/ceph-ansible/ansible.cfg
  configured module search path = ['/home/cephuser/ceph-ansible/library']
  ansible python module location = /usr/local/lib/python3.6/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.6.8 (default, Sep 10 2021, 09:13:53) [GCC 8.5.0 20210514 (Red Hat 8.5.0-3)]
#################################################################################################  
 

# copy config files 
sudo cp group_vars/all.yml.sample group_vars/all.yml	
vi group_vars/all.yml 

dummy:
ceph_release_num: 15
cluster: ceph
mon_group_name: mons
osd_group_name: osds
rgw_group_name: rgws
mds_group_name: mdss
nfs_group_name: nfss
rbdmirror_group_name: rbdmirrors
client_group_name: clients
iscsi_gw_group_name: iscsigws
mgr_group_name: mgrs
rgwloadbalancer_group_name: rgwloadbalancers
grafana_server_group_name: grafana-server
configure_firewall: True
ntp_service_enabled: true
ntp_daemon_type: chronyd
ceph_repository_type: cdn
ceph_origin: repository
ceph_repository: community
ceph_stable_release: octopus
monitor_interface: ens160
radosgw_interface: ens160
public_network: 192.168.198.0/24
cluster_network: 155.1.32.0/24
dashboard_enabled: True
dashboard_protocol: https
dashboard_port: 8443
dashboard_admin_user: admin
dashboard_admin_user_ro: false
dashboard_admin_password: p@ssw0rd
grafana_admin_user: admin
grafana_admin_password: admin



## osd configuration 

sudo cp group_vars/osds.yml.sample group_vars/osds.yml

sudo vim group_vars/osds.yml

---


dummy:
copy_admin_key: true
devices:
  - /dev/sdb
  - /dev/sdc
  - /dev/sdd



######################################################################################
[cephuser@ceph1 ceph-ansible]$ sudo cat  hosts
# Ceph admin user for SSH and sudo
[all:vars]
ansible_ssh_user=cephuser
ansible_become=true
ansible_become_method=sudo
ansible_become_user=root

#Ceph Monitor Nodes
[mons]
ceph1
ceph2
ceph3


#Ceph MDS Nodes
[mdss]
ceph1
ceph2
ceph3


#Ceph RGWS Nodes
[rgws]
ceph1
ceph2
ceph3

#Set OSD
[osds]
ceph1
ceph2
ceph3

#Grafan-Server
[grafana-server]
ceph1
ceph2
ceph3



##############################################################################

## Copy the site yaml 
sudo cp site.yml.sample site.yml

#Run the playbook 

ansible-playbook  -i hosts  site.yml   -vv 


