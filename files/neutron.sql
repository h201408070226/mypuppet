#create new database neutron and grant for neutron@localhost and neutron@%
create database neutron;
grant all privileges on neutron.* to 'neutron'@'localhost' identified by 'neutron_dbpass';
grant all privileges on neutron.* to 'neutron'@'%' identified by 'neutron_dbpass';

