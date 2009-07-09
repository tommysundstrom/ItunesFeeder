require 'rubygems'

# Some paths, etc.
ME = File.expand_path(__FILE__)
TEST_ROOT = File.dirname(ME)
TOP_DIR = File.dirname(TEST_ROOT) # (Note: This way to
      # find root is not safe inside the application, but here in test it's ok)
require File.join(TOP_DIR, 'require_app_files.rb')  # The module that handles application file loading
app_root = Require_app_files::application_files_directory(TOP_DIR)
Require_app_files::add_to_load_path_if_has_init(app_root)
Require_app_files::require_if_in_dir_with_init(app_root)


# This loads the application files the same way as it's done
      # when rb_main loads them.

=begin
app_root_if_app_files_in_application_dir = File.join(File.dirname(Test_root), 'application')
if File.exist?(app_root_if_app_files_in_application_dir)
  App_root = app_root_if_app_files_in_application_dir 
else
  # Since no application directory exist, we assumes that the files are in the root dir (and any subdir that has a __init__)
  App_root = File.dirname(Test_root)
end
=end

#Standardutilities_root = File.join(App_root, 'standardutilities')


# Set up paths
#   For stuff in sandbox
Sandbox = File.join(TEST_ROOT, 'sandbox')
new_gem_path = Gem.path + [Sandbox]
Gem.use_paths(nil, new_gem_path)
#   For stuff in sandbox lib
$LOAD_PATH << File.join(Sandbox, 'lib')
#   For other stuff
$: << '.'  # To load files like 'test/util'

# App and Standardutilities
#$LOAD_PATH << App_root
#$LOAD_PATH << Standardutilities_root

require 'test/unit'
require 'shoulda'
require 'assert2'
require 'log'