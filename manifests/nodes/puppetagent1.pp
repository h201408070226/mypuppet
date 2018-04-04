node 'puppetagent1' {
	#include openstackclient
	#include openstackselinux
	#file {"/tmp/test.txt":
	#     ensure=>file,
	#     content=>"test shibushi ",
	#}
	include stdlib
#	include nova_compute
#	include neutron_compute
	include cinder_compute
}
