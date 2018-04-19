class nova_compute{
	package{"openstack-nova-compute":
		ensure=>"installed",
		provider=>"yum",
	}
	file_line{"add Default":
		path=>"/etc/nova/nova.conf",
		match=>"^\[DEFAULT\]$",
		line=>"[DEFAULT]
		\nrpc_backend=rabbit
		\nauth_strategy=keystone
		\nmy_ip=192.168.188.133
		\nuse_neutron=True
		\nfirewall_driver=nova.virt.firewall.NoopFirewallDriver",
	}
	file_line{"add message to [oslo_messaging_rabbit]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[oslo_messaging_rabbit\]$",
		line=>"[oslo_messaging_rabbit]
		\nrabbit_host=puppetmaster
		\nrabbit_userid=openstack\
		nrabbit_password=RABBIT_PASS",
	}
	file_line{"add message to [keystone_authtoken]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[keystone_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri=http://puppetmaster:5000
		\nauth_url=http://puppetmaster:35357
		\nmemcached_servers=puppetmaster:11211
		\nauth_type=password
		\nproject_domain_name=default
		\nuser_domain_name=default
		\nproject_name=service
		\nusername=nova
		\npassword=nova",
	}
	file_line{"add message [vnc]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[vnc\]$",
		line=>'[vnc]
		\nenabled=True
		\nvncserver_listen=0.0.0.0
		\nvncserver_proxyclient_address=$my_ip
		\nnovncproxy_base_url=http://puppetmaster:6000/vnc_auto.html',
	}
	file_line{"add message [glance]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[glance\]$",
		line=>"[glance]
		\napi_servers=http://puppetmaster:9292",
	}
	file_line{"oslo_concurrency":
		path=>"/etc/nova/nova.conf",
		match=>"^\[oslo_concurrency\]$",
		line=>"[oslo_concurrency]
		\nlock_path=/var/lib/nova/tmp",
	}
	file_line{"add placement":
		path=>"/etc/nova/nova.conf",
		match=>"^\[placement\]$",
		line=>"[placement]
		\nauth_uri = http://controller:5000
		\nauth_url = http://controller:35357
		\nmemcached_servers = controller:11211
		\nauth_type = password
		\nproject_domain_name = default
		\nuser_domain_name = default
		\nproject_name = service
		\nusername = placement
		\npassword = placement
		\nos_region_name = RegionOne",
	}
	service{"openstack-nova-compute":
		ensure=>"running",
		enable=>true,
		hasrestart=>true,
		hasstatus=>true,
	}
	service{"libvirtd":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	Package['openstack-nova-compute']->File_line['add Default']->File_line['add message to [oslo_messageing_rabbit]']->
	File_line['add message to [keystone_authtoken]']->File_line['add message [vnc]']->File_line['add message [glance]']->
	File_line['oslo_concurrency']->File_line['add placement']->Service['openstack-nova-compute']->Service['libvirtd']

}
