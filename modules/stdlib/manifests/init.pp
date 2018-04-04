# Class: stdlib
#
# This module manages stdlib. Most of stdlib's features are automatically
# loaded by Puppet, but this class should be declared in order to use the
# standardized run stages.
#
# Parameters: none
#
# Actions:
#
#   Declares all other classes in the stdlib module. Currently, this consists
#   of stdlib::stages.
#
# Requires: nothing
#
class stdlib {
  include ::stdlib::stages
  file_line {"and a line":
      path=>"/tmp/result.txt",
      line=>"\najsdajdkasdjaskd", 
}
}
