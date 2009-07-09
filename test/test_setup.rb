require 'rubygems'

# Some paths, etc.
Me = File.expand_path(__FILE__)
Test_root = File.dirname(Me)
app_root_if_app_files_in_application_dir = File.join(File.dirname(Test_root), 'application') # (Note: This way to find root is not safe inside the application,
      # but here in test it's ok)
if File.exist?(app_root_if_app_files_in_application_dir)
  App_root = app_root_if_app_files_in_application_dir 
else
  # Since no application directory exist, we assumes that the files are in the root dir (and any subdir that has a __init__)
  App_root = File.dirname(Test_root)
end

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