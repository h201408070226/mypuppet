class openstackclient {
	package {"python-openstackclient":
		provider=>"yum",
		ensure=>installed,
	}
#	service {"python-openstackclient":
#		ensure=>running,
#		enable=>true, 
#	}
}
