#!/bin/sh
export OS_TOKEN=0045debd1ec5947082
export OS_URL=http://puppetmaster:35357/v3
export OS_IDENTITY_API_VERSION=3
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://puppetmaster:5000/v3
openstack endpoint create --region RegionOne identity internal http://puppetmaster:5000/v3
openstack endpoint create --region RegionOne identity admin http://puppetmaster:35357/v3
openstack domain create --description "Default Domain" default
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password-prompt admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --descroption "Demo Project" demo
openstack user create --domain default --password-prompt demo
openstack role create user
openstack role add --project demo --user demo user
unset OS_TOKEN OS_URL
openstack --os-auth-url http://puppetmaster:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue
openstack --os-auth-url http://puppetmaster:5000/v3 --os-project-domain-name default --os-user-doamin-name default --os-project-name demo --os-username demo token issue
source /etc/admin-openrc
openstack token issue

























