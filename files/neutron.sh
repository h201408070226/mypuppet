#!bin/sh
source /etc/mypuppet/admin-openrc
openstack user create --domain default --password-prompt neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://puppetmaster:9696
openstack endpoint create --region RegionOne network internal http://puppetmaster:9696
openstack endpoint create --region RegionOne network admin http://puppetmaster:9696
