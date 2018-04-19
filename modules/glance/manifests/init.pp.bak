class glance{
	file{"/etc/mypuppet/glance.sql":
			ensure=>file,
			source=>"puppet://puppetmaster/files/glance.sql",
			#subscribe => File['/etc/mypuppet'],
	}
	exec {"create new database glance":
		command=>'mysql -u root < /etc/mypuppet/glance.sql',
	  path=>"/usr/bin:/usr/sbin:/bin",
	  provider=>shell,
	}
	file{"/etc/mypuppet/glance.sh":
		ensure=>file,
		source=>"puppet://puppetmaster/files/glance.sh",
	}
	exec{"sh glance.sh":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"sh /etc/mypuppet/glance.sh",
		provider=>shell,
	}
	package{"openstack-glance":
		ensure=>"installed",
		provider=>"yum",
	}
	file_line{"add connection":
		path=>"/etc/glance/glance-api.conf",
		match=>"^\[database\]$",
		line=>"[database]
		\nconnection=mysql+pymysql://glance:glance_dbpass@puppetmaster/glance",
	}
	file_line{"rewirte keystone_authtoken":
		path=>"/etc/glance/glance-api.conf",
		match=>"^\[keystone\_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri=http://puppetmaster:5000
		\nauth_url=http://puppetmaster:35357
		\nmemcached_servers=puppetmaster:11211
		\nauth_type=password
		\nproject_domain_name=default
		\nuser_domain_name=default
		\nproject_name=service
		\nusername=glance
		\npassword=glance",
	}
	file_line{"add flavor to [paste_deploy]":
		path=>"/etc/glance/glance-api.conf",
		match=>"^\[paste\_deploy\]$",
		line=>"[paste_deploy]
		\nflavor=keystone",
	}
	file_line{"rewrite glance_store":
		path=>"/etc/glance/glance-api.conf",
		match=>"\[glance\_store\]$",
		line=>"[glance_store]
		\nstores=file,http
		\ndefault_store=file
		\nfilesystem_store_datadir=/var/lib/glance/images/",
	}
	file_line{"add connection to glance-registry.conf":
		path=>"/etc/glance/glance-registry.conf",
		match=>"^\[database\]$",
		line=>"[database]\nconnection=mysql+pymysql://glance:glance_dbpass@puppetmaster/glance",
	}
	file_line{"rewrite keystone_authtoken":
		path=>"/etc/glance/glance-registry.conf",
		match=>"^\[keystone\_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri=http://puppetmaster:5000
		\nauth_url=http://puppetmaster:35357
		\nmemcached_servers=puppetmaster:11211
		\nauth_type=password
		\npeoject_domain_name=default
		\nuser_domain_name=default
		\nproject_name=service
		\nusername=glance
		\npassword=glance",
	}
	file_line{"add flavor to paste_deploy":
		path=>"/etc/glance/glance-registry.conf",
		match=>"^\[paste\_deploy\]$",
		line=>"[paste_deploy]\nflavor=keystone",
	}
	exec{"add glance database":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"su -s /bin/sh -c 'glance-manage db_sync' glance",
	}
	service{"openstack-glance-api":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	service{"openstack-glance-registry":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	File['/etc/mypuppet/glance.sql']->Exec['create new database glance']->File['/etc/mypuppet/glance.sh']->
	Exec['sh glance.sh']->Package['openstack-glance']->File_line['add connection']->
	File_line['rewirte keystone_authtoken']->File_line['add flavor to [paste_deploy]']->File_line['rewrite glance_store']->
	File_line['add connection to glance-registry.conf']->File_line['rewrite keystone_authtoken']->File_line['add flavor to paste_deploy']->
	Exec['add glance database']->Service['openstack-glance-api']->Service['openstack-glance-registry']
}
