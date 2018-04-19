class placement{
	package{"openstack-nova-placement-api":
		ensure=>"installed",
		provider=>"yum",
	}
	exec{"rm -f /etc/httpd/conf.d/00-00-nova-placement-api.conf":
			path=>"/usr/bin:/usr/sbin:/bin",
			command=>"rm -f /etc/httpd/conf.d/00-00-nova-placement-api.conf",
			provider=>"shell",
	}
	file{"/etc/httpd/conf.d/00-00-nova-placement-api.conf":
			ensure=>file,
			source=>"puppet://puppetmaster/files/00-00-nova-placement-api.conf",
	}
	file{"/etc/mypuppet/placement.sh":
			ensure=>file,
			source=>"puppet://puppetmaster/files/placement.sh",
	}
	exec{"sh /etc/mypuppet/placement.sh":
		path=>"/usr/bin:/usr/sbin:bin"£¬
		command=>"sh /etc/mypuppet/placement.sh",
		provider=>"shell",
	}
	
	file_line{"add placement":
		path=>"/etc/nova/nova.conf",
		match=>"^\[placement\]$",
		line=>"[placement]
		\nauth_uri = http://puppetmaster:5000
		\nauth_url = http://puppetmaster:35357
		\nmemcached_servers = puppetmaster:11211
		\nauth_type = password
		\nproject_domain_name = default
		\nuser_domain_name = default
		\nproject_name = service
		\nusername = placement
		\npassword = placement
		\nos_region_name = RegionOne",
	}
	
	exec{"systemctl restart httpd":
		path=>"/usr/bin:/usr/sbin:bin"£¬
		command=>"systemctl restart httpd",
		provider=>"shell",
	}
	
	Package['openstack-nova-placement-api']->Exec['rm -f /etc/httpd/conf.d/00-00-nova-placement-api.conf']->File['/etc/httpd/conf.d/00-00-nova-placement-api.conf']->
	File['/etc/mypuppet/placement.sh']->Exec['sh /etc/mypuppet/placement.sh']->File_line['add placement']->
	Exec['systemctl restart httpd']

}
