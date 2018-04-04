class keystone{
	file{"/etc/mypuppet":
		ensure=>directory,
	}
	file{"/etc/mypuppet/keystone.sql":
			ensure=>file,
			source=>"puppet://puppetmaster/files/keystone.sql",
			#subscribe => File['/etc/mypuppet'],
	}
	exec {"create new database keystone":
		command=>'mysql -u root < /etc/mypuppet/keystone.sql',
	  path=>"/usr/bin:/usr/sbin:/bin",
	  provider=>shell,
	  #subscribe => File['/etc/mypuppet/keystone.sql'],
	}
	$admin_token=1234567890
	package{"openstack-keystone":
		provider=>"yum",
		ensure=>installed,
	}
	package{"httpd":
		provider=>"yum",
		ensure=>installed,
	}
	package{"mod_wsgi":
		provider=>"yum",
		ensure=>installed,
	}
	
	file_line {"add admin token":
		path=>"/etc/keystone/keystone.conf",
		#path=>"/tmp/test.txt",
		match=>'^\[DEFAULT\]$',
		replace=>true,
		line=>"[DEFAULT]\nadmin_token=$admin_token",
	}
	file_line {"add connection":
		path=>"/etc/keystone/keystone.conf",
		#path=>"/tmp/test.txt",
		match=>"^\[database\]$",
		line=>"[database]
		\nconnection=mysql+pymysql://keystone:keystone_dbpass@puppetmaster/keystone",
	}	
	file_line {"add token provider":
		path=>"/etc/keystone/keystone.conf",
		#path=>"/tmp/test.txt",
		match=>"^\[token\]$",
		line=>"[token]\nprovider=fernet",
	}
	exec{"keystone-manage db_sync":
		command=>'su -s /bin/sh -c "keystone-manage db_sync" keystone',
		path=>"/usr/bin:/usr/sbin:/bin",
		provider=>shell,
		#subscribe => File_line['add connection'],
	}
	exec{"for restart fernet keys":
		command=>"keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone",
		path=>"/usr/bin:/usr/sbin:/bin",
		#subscribe => File_line['add token provider'],
	}
	file_line{"add servername to httpd.conf":
		path=>"/etc/httpd/conf/httpd.conf",
		line=>"ServerName puppetmaster",
		#subscribe => Package['httpd'],
	}
	
	file{"/etc/httpd/conf.d/wsgi-keystone.conf":
		ensure=>file,
		source=>"puppet://puppetmaster/files/wsgi-keystone.conf",
	}
	file{"/etc/mypuppet/admin-openrc":
		ensure=>file,
		source=>"puppet://puppetmaster/files/admin_openrc.sh",
		#subscribe => File['/etc/mypuppet'],
	}
	file{"/etc/mypuppet/demo-openrc":
		ensure=>file,
		source=>"puppet://puppetmaster/files/demo_openrc.sh",
		#subscribe => File['/etc/mypuppet'],
	}
	file{"/etc/mypuppet/token.sh":
		ensure=>file,
		source=>"puppet://puppetmaster/files/token.sh",
		#subscribe => File['/etc/mypuppet'],
	}
	service {"httpd":
		ensure=>"running",
		enable=>true,
		hasstatus=>true,
		hasrestart=>true,
		require=>File['/etc/httpd/conf.d/wsgi-keystone.conf'],
	}
	file_line{"delete admin_auth_token from [pipeline:public_api]":
		path=>"/etc/keystone/keystone-paste.ini",
		match=>"^pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id admin_token_auth build_auth_context token_auth json_body ec2_extension public_service$",
		line=>"pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service",
		#before=>Exec['set environment'],
	}
	file_line{"delete admin_auth_token from [pipeline:admin_api]":
		path=>"/etc/keystone/keystone-paste.ini",
		match=>"^pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id admin_token_auth build_auth_context token_auth json_body ec2_extension s3_extension admin_service$",
		line=>"pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension admin_service",
		#before=>Exec['set environment'],
	}
	file_line{"delete admin_auth_token from [pipeline:api_v3]":
		path=>"/etc/keystone/keystone-paste.ini",
		match=>"^pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id admin_token_auth build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3$",
		line=>"pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension service_v3",
		#before=>Exec['set environment'],
	}
	exec{"set environment":
		command=>"sh /etc/mypuppet/token.sh",
		path=>"/usr/bin:/usr/sbin:/bin",
		provider=>shell,
		#require=>Service['httpd'],
	}
	File['/etc/mypuppet']->File['/etc/mypuppet/keystone.sql']->Exec['create new database keystone']->
	File_line['add admin token']->File_line['add connection']->File_line['add token provider']->
	Exec['keystone-manage db_sync']->Exec['for restart fernet keys']->Package['httpd']->
	File['/etc/httpd/conf.d/wsgi-keystone.conf']->Service['httpd']->File['/etc/mypuppet/admin-openrc']->
	File['/etc/mypuppet/demo-openrc']->File['/etc/mypuppet/token.sh']->File_line['delete admin_auth_token from [pipeline:public_api]']->
	File_line['delete admin_auth_token from [pipeline:admin_api]']->File_line['delete admin_auth_token from [pipeline:api_v3]']->Exec['set environment']
	
}
