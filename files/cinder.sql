#create new database neutron and grant for neutron@localhost and neutron@%
create database cinder;
grant all privileges on cinder.* to 'cinder'@'localhost' identified by 'cinder_dbpass';
grant all privileges on cinder.* to 'cinder'@'%' identified by 'cinder_dbpass';

