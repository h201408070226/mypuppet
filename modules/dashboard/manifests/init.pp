class dashboard{
	package{"openstack-dashboard":
		ensure=>installed,
		provider=>"yum",
	}
	file_line{"update OPENSTACK_HOST":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>'^OPENSTACK_HOST = "127.0.0.1"$',
		line=>'OPENSTACK_HOST = "puppetmaster"',
	}
	file_line{"update ALLOWED_HOSTS":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>"^ALLOWED_HOSTS = \['horizon.example.com', 'localhost'\]$",
		line=>"ALLOWED_HOSTS = ['*', ]",
	}
	file_line{"update CACHES":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>"^        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',$",
		line=>"         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
		         'LOCATION': 'puppetmaster:11211',"
	}
	file_line{"update OPENSTACK_KEYSTONE_URL":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>'^OPENSTACK_KEYSTONE_URL = "http://%s:5000/v2.0" % OPENSTACK_HOST$',
		line=>'OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST',
	}
	file_line{"update OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>"^#OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = False$",
		line=>"OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True",
	}
	file_line{"add OPENSTACK_API_VERSIONS":
		path=>"/etc/openstack-dashboard/local_settings",
		line=>'OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}',}
	file_line{"update OPENSTACK_KEYSTONE_DEFAULT_DOMAIN":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>"^#OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'default'$",
		line=>'OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"',
	}
	file_line{"update OPENSTACK_KEYSTONE_DEFAULT_ROLE":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>'^OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"$',
		line=>'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"',
	}
	file_line{"update OPENSTACK_NEUTRON_NETWORK":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>"^    'enable_fip_topology_check': True,$",
		line=>"    'supported_vnic_types': ['*'],
		'enable_router': False,
    'enable_quotas': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,",
	}
	file_line{"update TIME_ZONE":
		path=>"/etc/openstack-dashboard/local_settings",
		match=>'^TIME_ZONE = "UTC"$',
		line=>'TIME_ZONE = "Asia/Shanghai"',
	}
	exec{"restart httpd and memcached":
		path=>"/usr/bin:/use/sbin:/bin",
		command=>"systemctl restart httpd.service memcached.service",
		provider=>shell,
	}
	Package['openstack-dashboard']->File_line['update OPENSTACK_HOST']->File_line['update ALLOWED_HOSTS']->
	File_line['update CACHES']->File_line['update OPENSTACK_KEYSTONE_URL']->File_line['update OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT']->
	File_line['add OPENSTACK_API_VERSIONS']->File_line['update OPENSTACK_KEYSTONE_DEFAULT_DOMAIN']->File_line['update OPENSTACK_KEYSTONE_DEFAULT_ROLE']->
	File_line['update OPENSTACK_NEUTRON_NETWORK']->File_line['update TIME_ZONE']->
	Exec['restart httpd and memcached']
}