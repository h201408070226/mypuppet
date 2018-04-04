source /etc/mypuppet/admin-openrc
openstack user create --domain default --password=cinder cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack endpoint create --region RegionOne volume public http://puppetmaster:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://puppetmaster:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://puppetmaster:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 public http://puppetmaster:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://puppetmaster:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://puppetmaster:8776/v2/%\(tenant_id\)s
