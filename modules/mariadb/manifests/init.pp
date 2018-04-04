class mariadb {
	package { "mariadb":
		provider=>"yum",
		ensure=>installed,
	}
	package { "mariadb-server":
		provider=>"yum",
		ensure=>installed,
	}
	package { "python2-PyMySQL":
		provider=>"yum",
		ensure=>installed,
	}
	service { "mariadb":
		ensure=>running,
		hasstatus=>true,
		enable =>true,
	}
}
