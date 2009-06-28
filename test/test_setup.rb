require 'rubygems'

# Some paths, etc.
Me = File.expand_path(__FILE__)
Test_root = File.dirname(Me)
App_root = File.dirname(Test_root) # (Note: This way to find root is not safe inside the application,
      # but here in test it's ok)
Standardutilities_root = File.join(App_root, 'standardutilities')
Sandbox = File.join(Test_root, 'sandbox')

# Set up paths
#   For gems in sandbox
new_gem_path = Gem.path + [Sandbox]
Gem.use_paths(nil, new_gem_path)
#   For stuff in sandbox lib
$LOAD_PATH << File.join(Sandbox, 'lib')
#   For other stuff
$: << '.'  # To load files like 'test/util'

# App and Standardutilities
$LOAD_PATH << App_root
$LOAD_PATH << Standardutilities_root

require 'test/unit'
require 'shoulda'
require 'assert2'
require 'log'