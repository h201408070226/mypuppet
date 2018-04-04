node 'puppetmaster' {
	include openstackclient
	include openstackselinux
	include mariadb
#	include rabbitmq-server
	include memcached
	include stdlib
#	include keystone
#	include glance
#	include nova_controller
#	include neutron_controller
#	include dashboard
	include cinder_controller
	
}
