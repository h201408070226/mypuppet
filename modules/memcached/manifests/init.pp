class memcached {
	package { "memcached":
		provider=>"yum",
		ensure=>installed,
	}
	package {"python-memcached":
		provider=>"yum",
		ensure=>installed,
	}
	service {"memcached":
		ensure=>running,
		hasstatus=>true,
		hasrestart=>true,
		enable=>true,
	}
}
