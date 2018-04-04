#create new database and grant for keystone@localhost and keystone
#create database keystone;
#grant all privileges on keystone.* to 'keystone'@'localhost' identified by 'keystone_dbpass';
#grant all privileges on keystone.* to 'keystone'@'%' identified by 'keystone_dbpass';

#create new database glance and grant for glance@localshost and glance@%
#create database glance;
#grant all privileges on glance.* to 'glance'@'localhost' identified by 'glance_dbpass';
#grant all privileges on glance.* to 'glance'@'localhost' identified by 'glance_dbpass';

#create new database nova an grant for nova@localhost and nova@%
create database nova_api;
grant all privileges on nova_api.* to 'nova'@'localhost' identified by 'nova_dbpass';
grant all privileges on nova_api.* to 'nova'@'%' identified by 'nova_dbpass';
