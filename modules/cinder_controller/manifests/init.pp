class cinder_controller{
	file{"/etc/mypuppet/cinder.sql":
		ensure=>file,
		source=>"puppet://puppetmaster/files/cinder.sql",
	}
	exec{"create new database cinder":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"mysql -u root < /etc/mypuppet/cinder.sql",
		provider=>shell,
	}
	file{"/etc/mypuppet/cinder.sh":
		ensure=>file,
		source=>"puppet://puppetmaster/files/cinder.sh",
	}
	exec{"sh cinder.sh":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"sh /etc/mypuppet/cinder.sh",
		provider=>shell,
	}
	package{"openstack-cinder":
		ensure=>installed,
		provider=>"yum",
	}
	file_line{"add connection to cinder.conf [database]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[database\]$",
		line=>"[database]
		\nconnection=mysql+pymysql://cinder:cinder_dbpass@puppetmaster/cinder",
	}
	file_line{"add messages to cinder.conf [DEFAULT]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[DEFAULT\]$",
		line=>"[DEFAULT]
		\nrpc_backend = rabbit
		\nauth_strategy = keystone
		\nmy_ip = puppetmaster",
	}
	file_line{"add message to cinder.conf [oslo_messaging_rabbit]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[oslo_messaging_rabbit\]$",
		line=>"[oslo_messaging_rabbit]
		\nrabbit_host = puppetmaster
		\nrabbit_userid = openstack
		\nrabbit_password = RABBIT_PASS",
	}
	file_line{"add message to cinder.conf [keystone_authtoken]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[keystone_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri = http://puppetmaster:5000
		\nauth_url = http://puppetmaster:35357
		\nmemcached_servers = puppetmaster:11211
		\nauth_type = password
		\nproject_domain_name = default
		\nuser_domain_name = default
		\nproject_name = service
		\nusername = cinder
		\npassword = cinder",
	}
	file_line{"add message to cinder.conf [oslo_concurrency]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[oslo_concurrency\]$",
		line=>"[oslo_concurrency]\nlock_path = /var/lib/cinder/tmp",
	}
	exec{"cinder-manage db sync":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>'su -s /bin/sh -c "cinder-manage db sync" cinder',
		provider=>shell,
	}
	file_line{"add cinder message to nova.conf":
		path=>"/etc/nova/nova.conf",
		match=>"^\[cinder\]$"
		line=>"[cinder]\n
		os_region_name = RegionOne",
	}
	exec{"restart openstack-nova-api":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"systemctl restart openstack-nova-api",
		provider=>shell,
	}
	service{"openstack-cinder-api":
		ensure=>"running",
		enable=>true,
		hasrestart=>true,
		hasstatus=>true,
	}
	service{"openstack-cinder-scheduler":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	File['/etc/mypuppet/cinder.sql']->Exec['create new database cinder']->File['/etc/mypuppet/cinder.sh']->
	Exec['sh cinder.sh']->Package['openstack-cinder']->File_line['add connection to cinder.conf [database]']->
  File_line['add messages to cinder.conf [DEFAULT]']->File_line['add message to cinder.conf [oslo_messaging_rabbit]']->File_line['add message to cinder.conf [keystone_authtoken]']->
  File_line['add message to cinder.conf [oslo_concurrency]']->Exec['cinder-manage db sync']->File_line['add cinder message to nova.conf']->
	Exec['restart openstack-nova-api']->Service['openstack-cinder-api']->Service['openstack-cinder-scheduler']
}
