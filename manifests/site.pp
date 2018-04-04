#node 'puppetagent2' {
#          include openstackclient
#}
#node 'puppetmaster' {
#          include openstackclient
#}
#import "nodes/*.pp"
#node 'puppetmaster'{
#file_line{"add token":
#	path=>"/tmp/test.txt",
#	match=>"^guojixue_123456$",
#	line=>"[DEFAULT]\nXianhajdasdaksjda",
#
#}
#}

import "nodes/puppetmaster.pp"
import "nodes/puppetagent1.pp"