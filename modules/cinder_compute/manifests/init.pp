class cinder_compute{
	package{"lvm2":
		ensure=>installed,
		provider=>"yum",
	}
	service{"lvm2-lvmetad":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	exec{"pvcreate /dev/sdb":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"pvcreate /dev/sdb",
		provider=>shell,
	}
	exec{"vgcreate cinder-volumes /dev/sdb":
		path=>"/usr/bin:/usr/sbin:/bin",
		command=>"vgcreate cinder-volumes /dev/sdb",
		provider=>shell,
	}
	file_line{"add filter to device":
		path=>"/etc/lvm/lvm.conf",
		match=>"^devices {$",
		line=>'devices {
		filter = [ "a/sda/", "a/sdb/", "r/.*/"]',
	}
	package{"openstack-cinder":
		ensure=>installed,
		provider=>"yum",
	}
	package{"targetcli":
		ensure=>installed,
		provider=>"yum",
	}
	package{"python-keystone":
		ensure=>installed,
		provider=>"yum",
	}
	file_line{"add message to database":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[database\]$",
		line=>"[database]
		\nconnection=mysql+pymysql://cinder:cinder_dbpass@puppetmaster/cinder",
	}
	file_line{"add Default":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[DEFAULT\]$",
		line=>"[DEFAULT]
		\nrpc_backend=rabbit
		\nauth_strategy=keystone
		\nmy_ip=puppetagent1
		\nenabled_backends = lvm
		\nglance_api_servers = http://puppetmaster:9292",
	}
	file_line{"add message to [oslo_messageing_rabbit]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[oslo_messaging_rabbit\]$",
		line=>"[oslo_messaging_rabbit]
		\nrabbit_host=puppetmaster
		\nrabbit_userid=openstack
		\nrabbit_password=RABBIT_PASS",
	}
	file_line{"add message to [keystone_authtoken]":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[keystone_authtoken\]$",
		line=>"[keystone_authtoken]
		\nauth_uri=http://puppetmaster:5000
		\nauth_url=http://puppetmaster:35357
		\nmemcached_servers=puppetmaster:11211
		\nauth_type=password
		\nproject_domain_name=default
		\nuser_domain_name=default
		\nproject_name=service
		\nusername=cinder
		\npassword=cinder",
	}
	file_line{"add message [lvm]":
		path=>"/etc/cinder/cinder.conf",
		line=>"[lvm]
		\nvolume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
		\nvolume_group = cinder-volumes
		\niscsi_protocol = iscsi
		\niscsi_helper = lioadm",
	}
	file_line{"oslo_concurrency":
		path=>"/etc/cinder/cinder.conf",
		match=>"^\[oslo_concurrency\]$",
		line=>"[oslo_concurrency]
		\nlock_path=/var/lib/cinder/tmp",
	}
	service{"openstack-cinder-volume":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	service{"target":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
	}
	Package['lvm2']->Service['lvm2-lvmetad']->Exec['pvcreate /dev/sdb']->
  Exec['vgcreate cinder-volumes /dev/sdb']->File_line['add filter to device']->Package['openstack-cinder']->
	Package['targetcli']->Package['python-keystone']->File_line['add Default']->File_line['add message to database']->
	File_line['add message to [oslo_messageing_rabbit]']->File_line['add message to [keystone_authtoken]']->File_line['add message [lvm]']->
	File_line['oslo_concurrency']->Service['openstack-cinder-volume']->Service['target']
}
