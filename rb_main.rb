#
#  rb_main.rb
#  ItunesFeeder
#
#  Created by Tommy Sundström on 27/6-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'osx/cocoa'
require 'require_app_files'
require 'pp' # TEST  

def rb_main_init
  ##OSX::NSLog "rb_main_init" # TEST
  ##pp 'ARGV:'  # TEST
  ##pp ARGV
  ##OSX::NSLog "#{ARGV}"
=begin  # Moved to rb_main_tommys_extra_init  $LOAD_PATH << File.dirname(File.expand_path(__FILE__)) # TEST
  $LOAD_PATH << File.dirname(File.join(File.dirname(File.expand_path(__FILE__)), 'standardutilities')) # TEST
  pp $LOAD_PATH
  

  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
=end


  # OSX::NSLog "Orignal rb_main.rb extended with some additons by Tommy"

  # Require and load files Python init-style
  context = __FILE__
  #context = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation # The resource dir of the app. (This
        # is always (?) the dir where this file (rb_main.rb) is.)

  app_root = Require_app_files::application_files_directory(File.dirname(context))
  Require_app_files::add_to_load_path_if_has_init(app_root)
  Require_app_files::require_standardutilities
  Require_app_files::require_if_in_dir_with_init(app_root)
end

if $0 == __FILE__ then
  OSX::NSLog '---------- rb_main.rb started ----------'
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
