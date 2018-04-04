class neutron_compute{
	package{"openstack-neutron-linuxbridge":
		ensure=>installed,
		provider=>"yum",
	}
	package{"ebtables":
		ensure=>installed,
		provider=>"yum",
	}
	package{"ipset":
		ensure=>installed,
		provider=>"yum",
	}
	file_line{"add message to /etc/neutron/neutron.conf [DEFAULT]":
		path=>"/etc/neutron/neutron.conf",
		match=>"^\[DEFAULT\]$",
		line=>"[DEFAULT]
		\nrpc_backend = rabbit
		\nauth_strategy = keystone",
	}
	file_line{"add message to /etc/neutron/neutron.conf [oslo_messaging_rabbit]":
		path=>"/etc/neutron/neutron.conf",
		match=>"^\[oslo_messaging_rabbit\]$",
		line=>"[oslo_messaging_rabbit]
		\nrabbit_host = puppetmaster
		\nrabbit_userid = openstack
		\nrabbit_password = RABBIT_PASS",
	}
	file_line{"add message to /etc/neutron/neutron.conf [keystone_authtoken]":
		path=>"/etc/neutron/neutron.conf",
		match=>"^\[keystone_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri = http://puppetmaster:5000
		\nauth_url = http://puppetmaster:35357
		\nmemcached_servers = puppetmaster:11211
		\nauth_type = password
		\nproject_domain_name = default
		\nuser_domain_name = default
		\nproject_name = service
		\nusername = neutron
		\npassword = neutron",
	}
	file_line{"add message to /etc/neutron/neutron.conf [oslo_concurrency]":
		path=>"/etc/neutron/neutron.conf",
		match=>"^\[oslo_concurrency\]$",
		line=>"[oslo_concurrency]
		\nlock_path = /var/lib/neutron/tmp",
	}
	file_line{"add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini":
		path=>"/etc/neutron/plugins/ml2/linuxbridge_agent.ini",
		match=>"^\[linux_bridge\]$",
		line=>"[linux_bridge]
		\nphysical_interface_mappings = provider:ens33",
	}
	file_line{"add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini [vxlan]":
		path=>"/etc/neutron/plugins/ml2/linuxbridge_agent.ini",
		match=>"^\[vxlan\]$",
		line=>"[vxlan]
		\nenable_vxlan = True
		\nlocal_ip = 192.168.188.133
		\nl2_population = True",
	}
	file_line{"add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini [securitygroup]":
		path=>"/etc/neutron/plugins/ml2/linuxbridge_agent.ini",
		match=>"^\[securitygroup\]$",
		line=>"[[securitygroup]]
		\nenable_security_group = True
		\nfirewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver",
	}
	file_line{"add message to /etc/nova/nova.conf":
		path=>"/etc/nova/nova.conf",
		match=>"^\[neutron\]$",
		line=>"[neutron]
		\nurl = http://puppetmaster:9696
		\nauth_url = http://puppetmaster:35357
		\nauth_type = password
		\nproject_domain_name = default
		\nuser_domain_name = default
		\nregion_name = RegionOne
		\nproject_name = service
		\nusername = neutron
		\npassword = neutron",
	}
	exec{"restart nova-compute":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"systemctl restart openstack-nova-compute.service",
	}
	service{"neutron-linuxbridge-agent":
		ensure=>running,
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	Package['openstack-neutron-linuxbridge']->Package['ebtables']->Package['ipset']->
	File_line['add message to /etc/neutron/neutron.conf [DEFAULT]']->File_line['add message to /etc/neutron/neutron.conf [oslo_messaging_rabbit]']->File_line['add message to /etc/neutron/neutron.conf [keystone_authtoken]']->
	File_line['add message to /etc/neutron/neutron.conf [oslo_concurrency]']->File_line['add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini']->File_line['add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini [vxlan]']->
	File_line['add message to /etc/neutron/plugins/ml2/linuxbridge_agent.ini [securitygroup]']->File_line['add message to /etc/nova/nova.conf']->Exec['restart nova-compute']->
	Service['neutron-linuxbridge-agent']
}
