openstack user create --domain default --password=placement  placement
openstack role add --project service --user placement admin
openstack service create --name placement \
  --description "OpenStack Placement" placement
openstack endpoint create --region RegionOne \
  placement public http://puppetmaster:8778
openstack endpoint create --region RegionOne \
  placement internal http://puppetmaster:8778
openstack endpoint create --region RegionOne \
  placement admin http://puppetmaster:8778