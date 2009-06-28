#
#  rb_main.rb
#  ItunesFeeder
#
#  Created by Tommy Sundstršm on 27/6-09.
#  Copyright (c) 2009 Helt Enkelt ab. All rights reserved.
#

require 'osx/cocoa'
OSX::NSLog "Running rb_main.rb"

def rb_main_init
  OSX::NSLog "rb_main_init"
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end 

  rb_main_tommys_extra_init
end

def rb_main_tommys_extra_init
  OSX::NSLog "rb_main_tommys_extra_init"
  $LOAD_PATH << File.dirname(File.expand_path(__FILE__))  
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
