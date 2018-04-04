#!/bin/sh
source /etc/admin_openrc
openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstact endpoint create --region RegionOne compute public http:/puppetmaster:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://puppetmaster:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://puppetmaster:8774/v2.1/%\(tenant_id\)s
