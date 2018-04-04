class openstackselinux {
	package{"openstack-selinux":
		provider=>"yum",
		ensure=>installed,
}
}
