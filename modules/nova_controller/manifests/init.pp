class nova_controller{
#	$my_ip=puppetmaster
	file{"/etc/mypuppet/nova_api.sql":
			ensure=>file,
			source=>"puppet://puppetmaster/files/nova_api.sql",
			
	}
	exec {"create new database nova_api":
		command=>'mysql -u root < /etc/mypuppet/nova_api.sql',
	  path=>"/usr/bin:/usr/sbin:/bin",
	  provider=>shell,
	  #subscribe => File['/etc/mypuppet/keystone.sql'],
	}
	file{"/etc/mypuppet/nova.sql":
			ensure=>file,
			source=>"puppet://puppetmaster/files/nova.sql",
			
	}
	exec {"create new database nova":
		command=>'mysql -u root < /etc/mypuppet/nova.sql',
	  path=>"/usr/bin:/usr/sbin:/bin",
	  provider=>shell,
	}
	file{"/etc/mypuppet/nova_server.sh":
		ensure=>file,
	  source=>"puppet://puppetmaster/files/nova_server.sh",
	  
	}
	exec{"sh /etc/mypuppet/nova_server.sh":
		path=>"/usr/sbin:/usr/bin:/bin",
		command=>"sh /etc/mypuppet/nova_server.sh",
		provider=>shell,
	}
	package{"openstack-nova-api":
		ensure=>"installed",
		provider=>"yum",
	}
	package{"openstack-nova-conductor":
		ensure=>"installed",
		provider=>"yum",
	}
	package{"openstack-nova-console":
		ensure=>"installed",
		provider=>"yum",
	}
	package{"openstack-nova-novncproxy":
		ensure=>"installed",
		provider=>"yum",
	}
	package{"openstack-nova-scheduler":
		ensure=>"installed",
		provider=>"yum",
	}
	file_line{"add Default":
		path=>"/etc/nova/nova.conf",
		match=>"^\[DEFAULT\]$",
		line=>"[DEFAULT]
		\nenabled_apis=osapi_compute,metadata
		\nrpc_backend=rabbit
		\nauth_strategy=keystone
		\nmy_ip=puppetmaster
		\nuser_neutron=True
		\nfirewall_driver=nova.virt.firewall.NoopFirewallDriver",
	}
	file_line{"add connection to [api_database]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[api_database\]$",
		line=>"[api_database]
		\nconnection=mysql+pymysql://nova:nova_dbpass@puppetmaster/nova_api",
	}
	file_line{"add connection to [database]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[database\]$",
		line=>"[database]
		\nconnection=mysql+pymysql://nova:nova_dbpass@puppetmaster/nova",
	}
	file_line{"add message to [oslo_messageing_rabbit]":
		path=>"/etc/nova/nova.conf",
		match=>"^\[oslo_messageing_rabbit\]$",
		line=>"[oslo_messaging_rabbit]
		\nrabbit_host=puppetmaster
		\nrabbit_userid=openstack
		\nrabbit_password=RABBIT_PASS",
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
		line=>"[vnc]
		\nvncserver_listen=$my_ip
		\nvnc_server_proxyclient_address=$my_ip",
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
	exec{"nova_manage api_db":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>'su -s /bin/sh -c "nova-manage api_db sync" nova',
		provider=>shell,
	}
	exec{"nova_manage db":
		path=>"/usr/sbin:/usr/bin:/bin",
		command=>'su -s /bin/sh -c "nova-manage db sync" nova',
		provider=>shell,
	}
	service{"openstack-nova-api":
		ensure=>"running",
		enable=>true,
		hasrestart=>true,
		hasstatus=>true,
	}
	service{"openstack-nova-consoleauth":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	service{"openstack-nova-scheduler":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	service{"openstack-nova-conductor":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	service{"openstack-nova-novncproxy":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	File['/etc/mypuppet/nova_api.sql']->Exec['create new database nova_api']->file['/etc/mypuppet/nova.sql']->
	Exec['create new database nova']->File['/etc/mypuppet/nova_server.sh']->Exec['sh /etc/mypuppet/nova_server.sh']->
	Package['openstack-nova-api']->Package['openstack-nova-conductor']->Package['openstack-nova-console']->
	Package['openstack-nova-novncproxy']->Package['openstack-nova-scheduler']->File_line['add Default']->
	File_line['add connection to [api_database]']->File_line['add connection to [database]']->
	File_line['add message to [oslo_messageing_rabbit]']->File_line['add message to [keystone_authtoken]']->
	File_line['add message [vnc]']->File_line['add message [glance]']->File_line['oslo_concurrency']->
	Exec['nova_manage api_db']->Exec['nova_manage db']->Service['openstack-nova-api']->
	Service['openstack-nova-consoleauth']->Service['openstack-nova-scheduler']->Service['openstack-nova-conductor']->
	Service['openstack-nova-novncproxy']

}
